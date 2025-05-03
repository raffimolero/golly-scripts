local lib = require "./../../Mine/Scripts/lib"

--- @alias Shape [integer, integer][]
--- @alias Recipe [ [integer, integer, integer], [integer, integer, integer] ][][]

local t = -1
local CODE = { [0] = '.', [1] = 'J', [t] = 'V' }

local function wrap(str)
    return 'x = 0, y = 0, rule = TernaryJvN60\n' .. str .. '!'
end

local function pack(...)
    local out = flatten_deep({ ... })
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
        t0 = { 1, 0, 0 },
        t2 = { 0, 0, 1 },
        r = { 1, 0, 0 },
        u = { 1, 0, t },
        l = { 1, 1, 0 },
        d = { 1, 0, 1 },
    },
    d = {
        tap = t,
        t0 = { t, 0, 0 },
        t2 = { 0, 0, t },
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
        { codon,             code.d.t2 },
        { code.nop,          code.d.l },
        { code.c.t2,         code.d.t0 },
        { code.c.u,          code.nop },
        { pack(1, code.c.r), code.nop },
        { code.c.t0,         code.d.t2 },
        { code.nop,          code.d.d },
        { code.nop,          pack(t, code.c.r) },
    }
end

-- COMMON COMMANDS
local cmd = {
    intro = {
        { code.c.r, code.d.u },
        { code.c.r, code.d.u },
        { code.c.r, code.nop },
        { code.c.u, code.nop },
        { code.c.l, code.nop },
        { code.c.l, code.nop },
        { code.c.l, code.nop },
        { code.c.u, code.nop },
    },
    r = {
        { code.c.r, code.d.r },
    },
    ld = {
        { code.c.l,  code.nop },
        { code.c.t0, code.d.t2 },
        { code.nop,  code.d.d },
        { code.nop,  pack(t, code.d.r) },
        { code.c.t2, code.d.t0 },
    },
    su = {
        { code.c.u,  code.nop },
        { code.c.t0, code.nop },
    },

    cd = function(codon, cell)
        if cell == 0 then
            return {}
        end
        return {
            { code.nop,  codon },
            { code.c.t2, CODON[cell] },
        }
    end,
    cc = function(codon, cell)
        if cell == 0 then
            return {}
        end
        return {
            { codon,       code.nop },
            { CODON[cell], code.d.t2 },
        }
    end,
    l = function(cell)
        if not cell then
            return {
                { code.nop,          pack(t, code.d.l) },
                { code.c.t2,         code.d.t0 },
                { code.c.u,          code.nop },
                { pack(1, code.c.r), code.nop },
                { code.c.t0,         code.d.t2 },
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
            { CODON[cell],       code.d.t2 },
            { code.c.u,          code.nop },
            { pack(1, code.c.l), code.nop },
            { code.c.t0,         code.d.t2 },
            { code.c.r,          code.d.u },
            { code.nop,          code.d.r },
            { code.nop,          code.d.r },
        }
    end,
    prep = {
        { code.nop, code.d.d },
    },
    halt = {
        { { 0, 0, 0 }, { 0, 0, 0 } },
    }
}



---@return Recipe
local function build_recipe()
    --- @type Shape
    local moon = { { 0, 0 }, { 1, -1 }, { 1, -2 }, { 0, -3 } }

    ---@param shape Shape
    ---@param cx integer
    ---@param cy integer
    ---@return Shape
    local function get_cells_in_shape(shape, cx, cy)
        local function f(p)
            return g.getcell(cx + p.x, cy + p.y)
        end
        return map(moon, f)
    end

    local function shape_not_empty(shape, cx, cy)
        local function f(p)
            return g.getcell(cx + p[1], cy + p[2]) ~= 0
        end
        return any(shape, f)
    end

    local function compute_span(rect, y)
        local left = nil
        for x = rect.x - 1, rect.x + rect.w - 1 do
            if shape_not_empty(moon, x, y) then
                left = x
                break
            end
        end
        if left == nil then
            return nil, nil
        end
        local right = nil
        for x = rect.x + rect.w - 1, rect.x - 1, -1 do
            if shape_not_empty(moon, x, y) then
                right = x
                break
            end
        end
        if right == nil then
            panic('assertion violated in compute_span')
        end
        return left, right
    end

    local function construction_lanes(rect)
        local out = {}
        for y = rect.y + rect.h - 1, rect.y - 3, -4 do
            push(out, y)
        end
        return out
    end

    ---@type { x: integer, y: integer, w: integer, h: integer }
    local rect
    do
        local x, y, w, h = U(g.getselrect())
        rect = { x = x, y = y, w = w, h = h }
    end

    ---@type Recipe
    local recipe = {
        cmd.intro,
    }

    local start = true
    local lanes = construction_lanes(rect)
    local cx = rect.x - 1
    local cy = lanes[1] + 1
    local pl = cx
    for _, y in ipairs(lanes) do
        local l, r = compute_span(rect, y)
        if l == nil or r == nil then
            goto continue
        end

        if l < cx then
            -- local NORMAL_RIGHT_GREEN = 'K'
            -- push(recipe, { NORMAL_RIGHT_GREEN })
            local retract_target = math.max(pl, l)
            push(recipe, flatten_one(rep(concat(
                cmd.su, cmd.ld
            ), cx - retract_target)))
            cx = retract_target
        end
        if l < cx then
            -- local GATE_DOWN = 'V'
            -- push(recipe, { GATE_DOWN })
            push(recipe, {
                { code.c.l,          code.nop },
                { code.c.t0,         code.d.t0 },
                { code.c.u,          code.d.l },
                { pack(1, code.c.l), code.nop },
                { code.c.t0,         code.nop },
            })
            cx = cx - 1
            cy = cy - 1
            push(recipe, flatten_one(rep({
                { code.c.l, code.d.l }
            }, cx - l)))
            push(recipe, { { code.nop, code.d.u } })
            cx = l
        elseif l >= cx and not start then
            push(recipe, {
                { code.c.u,          code.nop },
                { pack(1, code.c.l), code.nop },
                { code.c.t0,         code.d.t2 },
            })
            cy = cy - 1
        end
        if cy ~= y then
            push(recipe, flatten_one(rep({
                { code.c.u, code.d.u }
            }, cy - y)))
            cy = y
            push(recipe, {
                { code.c.r, code.d.u },
                { code.nop, code.d.r },
                { code.nop, code.d.r },
            })
            pl = cx
        end
        start = false

        push(recipe, flatten_one(rep(cmd.r, r - cx)))
        push(recipe, cmd.prep)
        for x = r, l, -1 do
            push(recipe, cmd.cc(code.c.d, g.getcell(moon[1][1] + x, moon[1][2] + y)))
            push(recipe, cmd.cc(code.c.r, g.getcell(moon[2][1] + x, moon[2][2] + y)))
            push(recipe, cmd.su)
            push(recipe, cmd.cd(code.d.r, g.getcell(moon[3][1] + x, moon[3][2] + y)))
            push(recipe, cmd.cd(code.d.u, g.getcell(moon[4][1] + x, moon[4][2] + y)))
            push(recipe, cmd.ld)
        end
        cx = l
        ::continue::
    end

    local outro = concat(
        {
            {code.c.l, code.nop},
            {pack(1, code.c.l), code.nop},
        },
        rep({ code.c.l, code.nop }, 63),
        rep({ code.c.d, code.nop }, 70),
        { { { 1, 0, 0 }, code.nop } }
    )
    push(recipe, outro)
    push(recipe, cmd.halt)

    return recipe
end

-- RECIPE CODONS TO RLE
---@param recipe Recipe
---@return string
local function recipe_to_rle(recipe)
    local len = 0
    local lines = {
        {},
        {},
        {},
        {},
        {},
        {},
    }
    local comments = {}
    local comment = nil
    for _, group in ipairs(recipe) do
        for _, pair in ipairs(group) do
            if type(pair) == 'string' then
                comment = pair
                pair = { code.nop, code.nop }
            end
            push(comments, comment or '.')
            comment = nil
            len = len + 1
            for j, codon in ipairs(pair) do
                for i, trit in ipairs(codon) do
                    push(lines[(j - 1) * 3 + i], CODE[-trit])
                end
            end
        end
    end
    local out = ''
    push(lines, { len - 1 .. 'J' .. 'V' })
    for _, line in ipairs(lines) do
        out = out
            .. 'pJ$'
            .. len .. 'pGpJ$'
            .. len .. 'GpJ$'
            .. table.concat(line) .. '$'
            .. len + 1 .. 'I2$'
    end
    for i = 1, 5 do
        out = out .. table.concat(comments) .. '$'
    end
    return out
end

local function main()
    local recipe = build_recipe()
    local rle = recipe_to_rle(recipe)
    -- local pat = g.parse(rle)
    -- g.putcells(pat, 0, 0, 1, 0, 0, 1, 'copy')
    g.setclipstr(wrap(rle))
    -- g.paste(0, 0, 'copy')
end

main()
