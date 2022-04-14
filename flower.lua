local g = golly()
local gp = require "gplus"

-- Controls:
-- [Click+Drag] to start typing a construction tape.
-- Then, type in different numbers for different length signals.
-- You may also press [Space] to space out the signals.
-- If you make a mistake, press [q] to delete the last thing you typed.
-- [Shift+Q] will finish the script and remove the selection box.

---------------------------------------

g.show("Running program.")
g.setrule("Flow6")

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
-- program start

local ax, ay = nil, nil
local dx, dy = nil, nil
local mdown = false
local FINISHED = false

g.show("Running program.")
g.update()
g.setcursor("Select")

---------------------------------------
-- functions

local function cursor_is_ready()
	return
		not mdown
		and ax and ay
		and dx and dy
		and (dx ~= 0 or dy ~= 0)
end

local function place(cell)
	g.setcell(ax, ay, cell)
	ax = ax + dx
	ay = ay + dy
end

local function backspace()
	ax = ax - dx
	ay = ay - dy
	g.setcell(ax, ay, 0)
end

local function delete()
	local prev_cell = g.getcell(ax-dx, ay-dy)
	if prev_cell == 0 then return end
	repeat
		backspace()
		prev_cell = g.getcell(ax-dx, ay-dy)
	until prev_cell == 1 or prev_cell == 0
end

local function show_compass(length)
	length = length - 1
	local offx = dx < 0 and -length or 0
	local offy = dy < 0 and -length or 0
	local w = math.abs(dx) * length
	local h = math.abs(dy) * length
	g.select {
		ax + offx,
		ay + offy,
		w + 1,
		h + 1,
	}
end

local function show_cursor(span)
	span = span - 1
	local offx = math.abs(dy) * -span
	local offy = math.abs(dx) * -span
	g.select {
		ax + offx,
		ay + offy,
		-offx * 2 + 1,
		-offy * 2 + 1,
	}
end

---------------------------------------
-- event handling

local handler = {
	click = function(x, y, btn, mods)
		mdown = true
		ax, ay = x, y
	end,
	mup = function(btn)
		mdown = false
	end,
	key = function(key, mods)
		if key == "q" and mods.shift then
			FINISHED = true
			return
		end

		local function is_not_ready()
			if not cursor_is_ready() then
				g.note("Please set a proper direction for the tape.")
				return true
			end
			return false
		end

		if gp.validint(key) then
			if is_not_ready() then return end
			for i = 1, tonumber(key) do place(5) end
			place(2)
			place(1)
		elseif key == "delete" or key == "q" then
			if is_not_ready() then return end
			delete()
		elseif key == "space" then
			if is_not_ready() then return end
			place(1)
		end
		show_cursor(2)
	end,
}

repeat
	handle_event(handler)
	if mdown then
		dx, dy = get_direction(ax, ay, mouse_pos())
		show_compass(3)
	end
	g.update()
until FINISHED

---------------------------------------
-- end program

g.select({})
g.show("Done.")
