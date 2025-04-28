local g = golly()
local gp = require "gplus"


local CODE = {'.', 'J', 'V'}

local function wrap(str)
    return 'x = 0, y = 0, rule = TernaryJvN60\n' .. str .. '!'
end

local function gen(n)
    local str = ''
    for i = 1, n do
        str = str .. CODE[math.random(3)]
    end
    return str
end

g.setclipstr(wrap(gen(30)))
