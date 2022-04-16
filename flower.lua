local g = golly()
local gp = require "gplus"

-- Controls:
-- <Click+Drag> to start drawing a construction arm.
-- <Release> to begin typing the tape.
-- <Type> in different numbers for different length signals.
-- You may also press [Space] to space out the signals.
-- If you make a mistake, press [Delete], [Backspace], or [Tab] to undo the last signal input.
-- [Shift+S] will stop the script and remove the selection box.

-----------------------------------------

g.show("Running program.")
g.setrule("Flow6")

-----------------------------------------
-- framework

local MDOWN = false
local FINISHED = false

local function mouse_pos()
	local x, y = gp.split(g.getxy())
	return {
		x = tonumber(x),
		y = tonumber(y),
	}
end

local function modifiers(str)
	return {
		alt = str:find("alt") ~= nil,
		ctrl = str:find("ctrl") ~= nil,
		shift = str:find("shift") ~= nil,
	}
end

local function handle_event(handler)
	local event = g.getevent()
	if event == "" then return end
	local type, a, b, c, d = gp.split(event)

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

-----------------------------------------
-- History with cells

local History = {}

function History:reset()
	for i = 1, #self do
		self[i] = nil
	end
	self:push()
end

function History:rewind()
	self:pop(1)
	self:reset()
end

-- maybe there's a better way
local function clear_grid()
	local bounds = g.getrect()
	if #bounds == 0 then return end
	g.select(bounds)
    g.clear(0)
    g.select({})
end

function History:push()
    table.insert(self, {
        cells = g.getcells(g.getrect()),
        gen = g.getgen(),
    })
end

function History:pop(i)
    local frame = table.remove(self, i)
	if not frame then return end

    local cells = frame.cells
    local gen = frame.gen

	clear_grid()
    g.putcells(cells)
    g.setgen(gen)
    
    g.update()
end

-----------------------------------------
-- compass stuff

-- https://www.reddit.com/r/lua/comments/e11dsl/
local function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end

-- local function snap_to_direction(x, y)
-- 	if math.abs(y) > math.abs(x) then
-- 		return 0, sign(y)
-- 	else
-- 		return sign(x), 0
-- 	end
-- end

-- local function get_direction(a, b)
-- 	return snap_to_direction(b.x-a.x, b.y-a.y)
-- end

-----------------------------------------
-- Cursor

local Cursor = {}

function Cursor:reset()
	self.pos = nil
	self.dir = nil
end

function Cursor:show(span)
	if not self.pos then
		g.select({})
		return
	end

	span = span - 1
	local offx = 0
	local offy = 0

	if self.dir then
		offx = math.abs(self.dir.y) * span
		offy = math.abs(self.dir.x) * span
	end

	g.select {
		self.pos.x - offx,
		self.pos.y - offy,
		offx * 2 + 1,
		offy * 2 + 1,
	}
end

function Cursor:move()
	if not self.pos or not self.dir then return end
	self.pos = {
		x = self.pos.x + self.dir.x,
		y = self.pos.y + self.dir.y,
	}
end

function Cursor:move_by(direction)
	self.dir = direction
	self:move()
end

function Cursor:place(cell)
	g.setcell(self.pos.x, self.pos.y, cell)
end

function Cursor:push(cell)
	self:move()
	self:place(cell)
end

function Cursor:pop()
	self:place(0)
	if not self.dir then return end
	self.pos = {
		x = self.pos.x - self.dir.x,
		y = self.pos.y - self.dir.y,
	}
end

function Cursor:is_ready()
	return not MDOWN and self.pos and self.dir
end

-----------------------------------------
-- Recipe

local Recipe = {
	length = 0,
	step = 2,
}

function Recipe:reset()
	Cursor:reset()
	for i in ipairs(self) do
		self[i] = nil
	end
	self.length = 0
	self.step = 2
end

function Recipe:show()
	local out = ""
	for _,v in ipairs(self) do
		out = out..v
	end
	g.show(out)
end

function Recipe:finish()
	History:rewind()
	for _,v in ipairs(self) do
		self:insert(v)
	end
end

function Recipe:push(cell)
	-- if not Cursor.pos then return end
	Cursor:push(cell)
	self.length = self.length + 1
end

function Recipe:insert(len)
	for i=1, len do self:push(5) end
	if len ~= 0 then self:push(2) end
	self:push(1)
end

function Recipe:instruct(len)
	History:push()
	table.insert(self, len)
	self.step = self.step + 2

	Cursor:place(5)
	Cursor:push(5)
	g.run(len)
	Cursor:pop()
	Cursor:place(2)
	g.run(self.step + self.length)

end

function Recipe:undo()
	local len = table.remove(self)
	if not len then return end
	self.step = self.step - 2
	History:pop()
end

-----------------------------------------
-- Start

g.show("Running program.")
g.update()
g.setcursor("Select")

-----------------------------------------
-- event handling

local handler = {
	click = function(x, y, btn, mods)
		MDOWN = true
		g.setcursor("Draw")
		Recipe:reset()
		Cursor.pos = mouse_pos()
		Recipe:push(1)
	end,
	mup = function(btn)
		MDOWN = false
		g.setcursor("Select")
	end,
	key = function(key, mods)
		if key == "s" and mods.shift then
			FINISHED = true
			return
		end

		if gp.validint(key) then
			local len = tonumber(key)
			Recipe:instruct(len)
		elseif key == "space" then
			Recipe:instruct(0)
		elseif key == "delete" or key == "tab" then
			Recipe:undo()
		end

		Recipe:show()
		Cursor:show(2)
	end,
}

local function tick()
	if MDOWN then
		local pos = mouse_pos()
		if pos.x then
			local dx = sign(pos.x - Cursor.pos.x)
			while Cursor.pos.x ~= pos.x do
				Cursor.dir = { x=dx, y=0 }
				Recipe:push(1)
			end
		end
		if pos.y then
			local dy = sign(pos.y - Cursor.pos.y)
			while Cursor.pos.y ~= pos.y do
				Cursor.dir = { x=0, y=dy }
				Recipe:push(1)
			end
		end
		Cursor:show(2)
	end
end
repeat
	handle_event(handler)
	tick()
	g.update()
until FINISHED

Recipe:finish()
