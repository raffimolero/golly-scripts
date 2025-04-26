local g = golly()
local gp = require "gplus"

local HEADER = 'x = 0, y = 0, rule = TernaryJvN60\n'
local LEFT = '.$.$K$.$.'
local RIGHT = 'GpS$.pG$.G$.H$GH'
local NOSE = [[
x = 5, y = 5, rule = TernaryJvN60
$2pGpJ$2GJ$2.JV$3I!
]]

local function split(rle, delim)
    delim = delim or '$!'
    lines = {}
    for line in string.gmatch(rle, '[^' .. delim .. ']+') do
        table.insert(lines, line)
    end
    return lines
end

local function extract_rle(rle)
    local t = split(rle, '\n')
    table.remove(t, 1)
    return table.concat(t, '$')
end

local recipe_lines = split(LEFT)
local right_lines = split(RIGHT)

rect = g.getselrect()
local x, y, w, h = table.unpack(rect)
local U = { [7] = '.', [11] = 'H', [15] = 'T' }
local D = { [7] = '.', [11] = 'J', [15] = 'V' }

for i = x + w - 1, x, -1 do
    local u = g.getcell(i, y)
    local d = g.getcell(i, y + 1)
    recipe_lines[2] = recipe_lines[2] .. '.' .. (U[u] or '.')
    recipe_lines[4] = recipe_lines[4] .. '.' .. (D[d] or '.')

    recipe_lines[3] = recipe_lines[3] .. 'GpS'
end
recipe_lines[1] = recipe_lines[1] .. '.' .. w * 2 - 1 .. 'G'
recipe_lines[5] = recipe_lines[1]

for i = 1, #right_lines do
    recipe_lines[i] = recipe_lines[i] .. right_lines[i]
end
g.setclipstr(HEADER .. table.concat(recipe_lines, '$\n') .. '!')
