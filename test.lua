local g = golly()
local gp = require("gplus")

---------------------------------------
-- helpers

local function mouse_pos()
	local x, y = gp.split(g.getxy())
	return tonumber(x) or 0, tonumber(y) or 0
end

-- https://www.reddit.com/r/lua/comments/e11dsl/
local function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

local function modifiers(str)
	return {
		alt = str:find("alt") ~= nil,
		ctrl = str:find("ctrl") ~= nil,
		shift = str:find("shift") ~= nil,
	}
end

---------------------------------------
-- framework

local function handle_event(handler)
	local event = g.getevent()
	if event == "" then return end
	type, a, b, c, d = gp.split(event)

	local func = handler[type]

	if func then
		local args
		if type == "key" then
			args = {a, modifiers(b)}
		elseif type == "click" then
			args = {tonumber(a), tonumber(b), c, modifiers(d)}
		elseif type == "mup" then
			args = {a}
		else
			g.note("Event type "..type.." is not supported.")
		end
		func(table.unpack(args))
	else
		g.doevent(event)
	end
end

---------------------------------------
-- compass stuff

local function snap_to_direction(x, y)
	if math.abs(y) > math.abs(x) then
		return 0, sign(y)
	else
		return sign(x), 0
	end
end

local function get_direction(ax, ay, bx, by)
	return snap_to_direction(bx-ax, by-ay)
end

---------------------------------------
-- History with cells

local History = {}

function History:push()
    local bounds = g.getrect()
    table.insert(self, {
        bounds = bounds,
        cells = g.getcells(bounds),
        gen = g.getgen(),
    })
end

function History:pop()
    local frame = table.remove(self)

    local bounds = frame.bounds
    local cells = frame.cells
    local gen = frame.gen

    local x, y = bounds[1], bounds[2]
    local w, h = bounds[3], bounds[4]

    -- clear all cells, maybe there's a better way
    g.select(g.getrect())
    g.clear(0)
    g.select({})

    -- paste all cells
    g.putcells(cells, 0, 0, 1, 0, 0, 1, "copy")

    g.setgen(gen)
    
    g.update()
end

-----------------------------------------

History:push()

g.run(4)
g.update()

History:pop()
g.update()
