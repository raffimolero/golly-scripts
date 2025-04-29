local g = golly()
local gp = require "gplus"

local function err(msg)
    g.error(msg)
    g.exit(msg)
end

local t = -1
local CODE = { [0] = '.', [1] = 'J', [t] = 'V' }

local function wrap(str)
    return 'x = 0, y = 0, rule = TernaryJvN60\n' .. str .. '!'
end

local function flatten(item, result)
    local result = result or {}
    if type(item) == 'table' then
        for k, v in pairs(item) do
            flatten(v, result)
        end
    else
        result[#result + 1] = item
    end
    return result
end

local function pack(...)
    local out = flatten({ ... })
    while #out > 3 do
        if table.remove(out) ~= 0 then
            err('attempted to pack too many trits into one codon')
        end
    end
    return out
end

-- INDIVIDUAL CODONS
local code = {
    nop = { 0, 0, 0 },
    dia = { 1, 1, 1 },
    c = {
        tap = 1,
        r = { 1, 0, 0 },
        u = { 1, 0, t },
        l = { 1, 1, 0 },
        d = { 1, 0, 1 },
    },
    d = {
        tap = t,
        r = { t, 0, 0 },
        u = { t, 0, 1 },
        l = { t, t, 0 },
        d = { t, 0, t },
    },
    g = {
        r = { 1, 1, t },
        u = { 1, t, t },
        l = { 1, t, 0 },
        d = { 1, t, 1 },
    },
}
local CODON = {
    [0] = code.nop,
    [7] = code.c.r,
    [8] = code.c.u,
    [9] = code.c.l,
    [10] = code.c.d,
    [19] = code.g.r,
    [20] = code.g.u,
    [21] = code.g.l,
    [22] = code.g.d,
    [31] = code.d.r,
    [32] = code.d.u,
    [33] = code.d.l,
    [34] = code.d.d,
    [43] = code.dia,
}

local function build(codon)
    return {
        { codon,             { 0, 0, t } },
        { code.nop,          code.d.l },
        { { 0, 0, 1 },       { t, 0, 0 } },
        { code.c.u,          code.nop },
        { pack(1, code.c.r), code.nop },
        { { 1, 0, 0 },       { 0, 0, t } },
        { code.nop,          code.d.d },
        { code.nop,          pack(t, code.c.r) },
    }
end

-- COMMON COMMANDS
local function rep(group, count)
    local out = {}
    for i = 1, count do
        for _, pair in ipairs(group) do
            table.insert(out, pair)
        end
    end
    return out
end

local cmd = {
    intro = {
        { code.c.r, code.d.u },
        { code.c.r, code.d.u },
        { code.c.r, code.d.u },
        { code.c.u, code.d.r },
        { code.c.l, code.d.r },
        { code.c.l, code.nop },
        { code.c.l, code.nop },
        { code.c.u, code.nop },
        { code.c.r, code.nop },
    },
    r = {
        { code.c.r, code.d.r },
    },
    l = function(cell)
        if not cell then
            return {
                { code.nop,          pack(t, code.d.l) },
                { { 0, 0, 1 },       { t, 0, 0 } },
                { code.c.u,          code.nop },
                { pack(1, code.c.r), code.nop },
                { { 1, 0, 0 },       { 0, 0, t } },
                { code.nop,          code.d.d },
                { code.nop,          pack(t, code.c.r) },
            }
        else
            return build(CODON[cell])
        end
    end,
    u = function(cell)
        cell = cell or 0
        return {
            { CODON[cell],       { 0, 0, t } },
            { code.c.u,          code.nop },
            { pack(1, code.c.l), code.nop },
            { { 1, 0, 0 },       { 0, 0, t } },
            { code.c.r,          code.d.u },
            { code.nop,          code.d.r },
            { code.nop,          code.d.r },
        }
    end,
    prep = {
        { code.c.r, code.d.d },
    },
    halt = {
        { { 0, 0, 0 }, { 0, 0, 0 } },
    }
}

-- SELECTION TO RECIPE CODONS
local rect = g.getselrect()
local x, y, w, h = table.unpack(rect)
local recipe = {
    cmd.intro,
}

for cy = y + h - 1, y, -1 do
    table.insert(recipe, rep(cmd.r, w - 1))
    table.insert(recipe, cmd.prep)
    for cx = x + w - 1, x, -1 do
        table.insert(recipe, cmd.l(g.getcell(cx, cy)))
    end
    table.insert(recipe, cmd.u())
end
-- wrap around and activate child clock
table.insert(recipe, rep({ { code.c.u, code.nop } }, 2))
table.insert(recipe, rep({ { code.c.l, code.nop } }, 13))
table.insert(recipe, rep({ { code.c.d, code.nop } }, 107))
table.insert(recipe, { { { 1, 0, 0 }, code.nop } })
-- halt
table.insert(recipe, cmd.halt)


-- RECIPE CODONS TO RLE
local len = 0
local lines = {
    {},
    {},
    {},
    {},
    {},
    {},
}
for _, group in ipairs(recipe) do
    for _, pair in ipairs(group) do
        len = len + 1
        for j, codon in ipairs(pair) do
            for i, trit in ipairs(codon) do
                table.insert(lines[(j - 1) * 3 + i], CODE[-trit])
            end
        end
    end
end
local out = ''
table.insert(lines, { len - 1 .. 'J' .. 'V' })
for _, line in ipairs(lines) do
    out = out
        .. 'pJ$'
        .. len .. 'pGpJ$'
        .. len .. 'GpJ$'
        .. table.concat(line) .. '$'
        .. len + 1 .. 'I2$'
end
out = wrap(out)

-- OUTPUT
g.setclipstr(out)
