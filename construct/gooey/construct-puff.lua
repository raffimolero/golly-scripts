-- Modified script from user 'islptng'
-- https://conwaylife.com/forums/viewtopic.php?f=11&t=3537&p=200337#p200337

local g = golly()
local gp = require "gplus"

function flatten_deep(t)
    local out = {}
    local function inner(t)
        for _, v in ipairs(t) do
            if type(v) == "table" then
                inner(v)
            else
                table.insert(out, v)
            end
        end
    end
    inner(t)
    return out
end

local function rep(item, count)
    local out = {}
    for i = 1, count do table.insert(out, item) end
    return out
end

-- Encoding systems
local LEN_PUSH = 6
local LEN_FIRE = 16
local LEN_WAIT = 20
local LEN_MAKE = 28
local LEN_PULL = 36

local COMBO_PUSH = { LEN_PUSH }
local COMBO_FIRE = { LEN_FIRE, LEN_WAIT, LEN_PUSH }
local COMBO_WAIT = { LEN_WAIT }
local COMBO_MAKE = { COMBO_FIRE, LEN_MAKE }
local COMBO_PULL = { COMBO_FIRE, LEN_PULL }

local INSTRUCT_PUSH = { COMBO_PUSH }
local INSTRUCT_FIRE = { COMBO_FIRE, COMBO_PUSH }
local INSTRUCT_WAIT = { COMBO_WAIT }
local INSTRUCT_MAKE = { COMBO_MAKE, COMBO_PUSH, rep(INSTRUCT_FIRE, 7) }
local INSTRUCT_PULL = { COMBO_PULL }

-- Read input

local r = gp.rect(g.getselrect())
if r.empty then g.exit("There is no selection.") end

local oldsecs = os.clock()
local maxstate = g.numstates() - 1

g.copy()
local PRINTER = {
    x = -2,
    y = -128,
    dy = 64,
    rle = g.getclipstr()
}

g.clear(0)
g.setclipstr(PRINTER.rle:gsub("BA", ""))
g.paste(r.left, r.top, "or")

local tape = {}

for col = r.right, r.left, -1 do
    -- if large selection then give some indication of progress
    local newsecs = os.clock()
    if newsecs - oldsecs >= 1.0 then
        oldsecs = newsecs
        g.update()
    end

    for row = r.bottom, r.top, -1 do
        if g.getcell(col, row) == 1 then
            table.insert(tape, {
                INSTRUCT_MAKE,
                rep(INSTRUCT_FIRE, row - r.top)
            })
        end
    end
    table.insert(tape, INSTRUCT_PUSH)
end


-- HACK: hardcode tape
-- tape = {COMBO_MAKE}

local function pow2(n)
    local x = 1
    while x < n do x = x * 2 end
    return x
end

local body = "BA"
local width = 2
for _, len in ipairs(flatten_deep(tape)) do
    width = width + len
    body = body .. tostring(len - 2) .. ".BA"
end
local rle = "x = " .. tostring(width) .. PRINTER.rle:sub(PRINTER.rle:find(","), -1):gsub("BA", body)

-- g.duplicate()
g.setclipstr(rle)
g.show("Printer RLE copied to clipboard.")
g.clear(0)
g.paste(r.right + PRINTER.x, r.top + PRINTER.y, "or")
g.setclipstr(PRINTER.rle:gsub("BA", ""))
g.paste(r.right + PRINTER.x + pow2(width / 2), r.top + PRINTER.y + PRINTER.dy, "or")
