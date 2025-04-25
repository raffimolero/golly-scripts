-- Modified script from user 'islptng'
-- https://conwaylife.com/forums/viewtopic.php?f=11&t=3537&p=200337#p200337

local g = golly()
local gp = require "gplus"

function flatten(t)
    local out = {}
    local function inner(t)
        for _, v in ipairs(t) do
            if type(v) == "table" then inner(v)
            else table.insert(out, v) end
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

local COMBO_PUSH = {LEN_PUSH}
local COMBO_FIRE = {LEN_FIRE, LEN_WAIT, LEN_PUSH}
local COMBO_WAIT = {LEN_WAIT}
local COMBO_MAKE = {COMBO_FIRE, LEN_MAKE}
local COMBO_PULL = {COMBO_FIRE, LEN_PULL}

local INSTRUCT_PUSH = {COMBO_PUSH}
local INSTRUCT_FIRE = {COMBO_FIRE, COMBO_PUSH}
local INSTRUCT_WAIT = {COMBO_WAIT}
local INSTRUCT_MAKE = {COMBO_MAKE, COMBO_PUSH, rep(INSTRUCT_FIRE, 16)}
local INSTRUCT_PULL = {COMBO_PULL}

-- Read input

local r = gp.rect(g.getselrect())
if r.empty then g.exit("There is no selection.") end

local oldsecs = os.clock()
local maxstate = g.numstates() - 1

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


local PRINTER = {
    x = -2,
    y = -71,
    w = 65,
    h = 73,
    top = [[
11.A$11.A39.A$51.A2$7.A3.A7.3A2.2A$7.A3.A39.A6.3A2.2A$11.A39.A$29.A
21.A$7.A15.3A3.2A$7.A23.A13.A$7.A23.A13.A2$19.A$19.A$19.A35.2A$11.3A
2.2A$A$19.A3.A$11.3A2.2A.A3.A$23.A31.2A$3.2A$48.2A2$31.A$31.A$31.A23.
2A$11.A17.A25.A$11.A17.A15.A9.2A$11.A11.3A3.A15.A12.A$45.A12.A6.
    ]],
    bottom = [[
$58.A$
29.A$29.A21.A$39.A11.A$25.3A11.A11.A2.A3.3A2.2A3$39.A11.A$39.A11.A$
39.A5.3A3.A2$6.A38.A$6.A38.A$6.A4.3A2.2A2$45.A$6.A22.A15.A$6.A22.A5.
2A2.3A3.A4$49.3A2.2A2$37.A7.A$23.3A11.2A6.A5$23.A13.A$23.A13.A$23.A7.
3A3.A2$29.A$29.A$19.2A2.3A3.A4$35.3A2.2A2$29.A$29.A!
    ]]
}

local body = "BA"
local width = 2
for _, len in ipairs(flatten(tape)) do
    width = width + len
    body = body .. tostring(len - 2) .. ".BA"
end
local rle = "x = " .. PRINTER.w + width .. ", y = " .. PRINTER.h .. ", rule = Gooey\n" .. PRINTER.top .. body .. PRINTER.bottom

-- g.duplicate()
g.setclipstr(rle)
g.show("Printer RLE copied to clipboard.")
g.clear(0)
g.paste(r.right + PRINTER.x, r.top + PRINTER.y, "or")
