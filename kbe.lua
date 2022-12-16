--------------------------------------------------------------------------------
-- it's like vim for golly or something idk
-- edit these however you like
-- it's not my fault if you break it but you can always redownload my version

-- you can type numbers to repeat your actions a specific number of times
-- for example, typing 10 will make all further actions repeat 10 times
-- very useful for moving around quickly and selecting large patters
-- if you hold space, typing hjlk in that order will draw a hollow 11 by 11 square SE of your cursor
-- you could also use it to switch states, maybe there are rules where only every 3 states is relevant
-- reset this number by pressing this keybind
REPS_RESET_BIND = ';'

Binds = {
	-- these binds work in edit mode, but you can hold shift to use them in text mode
	common = {
		-- deletes the ones digit of your number
		delete = function() reps_pop() return CANCEL end,

		-- sets the zoom level
		a = function() zoom(1) end,
		z = function() zoom(-1) end,

		-- movement
		k = function(mods) Cursor:move_input(0, -1, mods) return MOVE end, -- up
		j = function(mods) Cursor:move_input(0, 1, mods) return MOVE end,  -- down
		h = function(mods) Cursor:move_input(-1, 0, mods) return MOVE end, -- left
		l = function(mods) Cursor:move_input(1, 0, mods) return MOVE end,  -- right

		-- holding this while moving will pan the screen without moving the cursor
		-- unless you hold a key labeled DURING_MOVE or AFTER_MOVE,
		-- in that case it might do something else, see the rotate and flip commands further below
		special_mod = 'alt',
		-- holding this while moving leaves the "anchor" in place so you can resize the selection
		anchor_mod = 'shift',

		-- these change the cell state of the cursor
		q = function() Cursor:change_state(-1) end,
		e = function() Cursor:change_state(1) end,
		s = function() Cursor:set_state(REPS) return RESET end,

		-- here are your selection manipulation operations
		-- sadly no rotations or flips yet
		-- holding these, then moving, will perform them after the move
		-- so for example, 10pllll will paste once, then 4 more times every 10 cells to the right
		-- might be useful for tiling patterns
		x = function() Cursor:clear() return AFTER_MOVE end,
		d = function() Cursor:copy() Cursor:clear() return AFTER_MOVE end,
		y = function() Cursor:copy() return AFTER_MOVE end,
		p = function() Cursor:paste() return AFTER_MOVE end,
		c = function() Cursor:paste('copy') return AFTER_MOVE end,

		-- rotation defaults to clockwise, hold special_mod to make it counterclockwise
		-- hold anchor_mod to keep your selection box in place
		r = function(mods) Cursor:rotate(mods) return AFTER_MOVE end,

		-- flips default to horizontal, hold special_mod to make it vertical
		f = function(mods) Cursor:flip(mods) return AFTER_MOVE end,
	},

	-- these only work in edit mode, the default mode
	edit = {
		-- typing a colon quits the script
		-- if you don't quit the script properly, the cursor head and selection will just hang out
		[':'] = function() quit() return RESET end,

		-- goes into text mode
		i = function() Cursor:toggletext() return RESET end,

		-- place the selected cell state down
		-- holding this while moving will draw a line
		space = function() Cursor:place() return DURING_MOVE end,

		-- pick the color under your cursor head with this
		w = function() Cursor:pick() end,
	},

	text = {
		-- text keybinds only work if you hold the escape mod
		-- otherwise you'd just type normal letters
		escape_mod = 'ctrl',

		-- ctrl+enter returns to edit mode
		['return'] = function() Cursor:toggletext() return RESET end,

		-- ctrl+hjkl now move by 4x and 6y; most characters are 3 by 5
		-- be careful, moving your cursor this way will cause it to forget what you have typed
		-- this means you can no longer delete different width characters, and especially newlines

		-- ctrl+q/e/s still work fine, they change your "font color"
		-- selection manipulation still works as usual

		-- use ctrl+<num> to type numbers
		-- use ctrl+; to reset, or whatever you bound that to
		-- yes, you can type multiple letters at once, don't ask
	}
}

for k,v in pairs(Binds.common) do
	Binds.edit[k] = v
	Binds.text[k] = v
end

-- if you have any objections or suggestions for the font change them here
font = {
	['return'] = function() Cursor:crlf() return RESET end,
	delete = function() Cursor:backspace() end,

	-- there is an automatic +1 width for all characters
	-- if the width is not specified it defaults to 3
	space = {'!', 1},
	tab = {'!', 7},

	a = {'.A$A.A$3A$A.A$A.A!'},
	b = {'2A$A.A$2A$A.A$2A!'},
	c = {'.2A$A$A$A$.2A!'},
	d = {'2A$A.A$A.A$A.A$2A!'},
	e = {'3A$A$2A$A$3A!'},
	f = {'3A$A$2A$A$A!'},
	g = {'.2A$A$A.A$A.A$.2A!'},
	h = {'A.A$A.A$3A$A.A$A.A!'},
	i = {'3A$.A$.A$.A$3A!'},
	j = {'.2A$2.A$2.A$A.A$.A!'},
	k = {'A.A$A.A$2A$A.A$A.A!'},
	l = {'A$A$A$A$3A!'},
	m = {'A.A$3A$A.A$A.A$A.A!'},
	n = {'2A$A.A$A.A$A.A$A.A!'},
	o = {'.A$A.A$A.A$A.A$.A!'},
	p = {'2A$A.A$2A$A$A!'},
	q = {'.A$A.A$A.A$A.A$.2A!'},
	r = {'2A$A.A$2A$A.A$A.A!'},
	s = {'.2A$A$.A$2.A$2A!'},
	t = {'3A$.A$.A$.A$.A!'},
	u = {'A.A$A.A$A.A$A.A$.2A!'},
	v = {'A.A$A.A$A.A$A.A$.A!'},
	w = {'A.A$A.A$A.A$3A$A.A!'},
	x = {'A.A$A.A$.A$A.A$A.A!'},
	y = {'A.A$A.A$.A$.A$.A!'},
	z = {'3A$2.A$.A$A$3A!'},

	['0'] = {'.2A$A.A$A.A$A.A$2A!'},
	['1'] = {'.A$2A$.A$.A$3A!'},
	['2'] = {'2A$2.A$.A$A$3A!'},
	['3'] = {'2A$2.A$.A$2.A$2A!'},
	['4'] = {'A.A$A.A$.2A$2.A$2.A!'},
	['5'] = {'3A$A$.A$2.A$2A!'},
	['6'] = {'.2A$A$3A$A.A$2A!'},
	['7'] = {'3A$2.A$.A$.A$.A!'},
	['8'] = {'.2A$A.A$.A$A.A$2A!'},
	['9'] = {'.2A$A.A$3A$2.A$2A!'},

	['`'] = {'A$.A!', 2},
	['~'] = {'.A.A$A.A!', 4},
	['!'] = {'A$A$A2$A!', 1},
	['@'] = {'.3A$A.2A$A.2A$A$.3A!', 4},
	['#'] = {'.A.A$5A$.A.A$5A$.A.A!', 5},
	['$'] = {'.4A$A.A$.3A$2.A.A$4A!', 5},
	['%'] = {'A.A$2.A$.A$A$A.A!'},
	['^'] = {'.A$A.A!'},
	['&'] = {'.A$A.A$.A$A2.A$.2A!', 4},
	['*'] = {'$A.A$.A$A.A!'},
	['('] = {'.A$A$A$A$.A!', 2},
	[')'] = {'A$.A$.A$.A$A!', 2},
	['['] = {'2A$A$A$A$2A!', 2},
	[']'] = {'2A$.A$.A$.A$2A!', 2},
	['{'] = {'.2A$.A$A$.A$.2A!'},
	['}'] = {'2A$.A$2.A$.A$2A!'},
	[','] = {'3$A$A!', 1},
	['<'] = {'$.A$A$.A!', 2},
	['.'] = {'4$A!', 1},
	['>'] = {'$A$.A$A!', 2},
	['-'] = {'2$3A!'},
	['_'] = {'4$3A!'},
	['+'] = {'$.A$3A$.A!'},
	['='] = {'$3A2$3A!'},
	[';'] = {'$A2$A$A!', 1},
	[':'] = {'$A2$A!', 1},
	['/'] = {'2.A$.A$.A$.A$A!'},
	['?'] = {'2A$2.A$.A2$.A!'},
	['\\'] = {'A$.A$.A$.A$2.A!'},
	['|'] = {'A$A$A$A$A$!', 1},
	["'"] = {'A$A!', 1},
	['"'] = {'A.A$A.A!'},
}

-----------------------------------------
-- message

function info(t)
	if type(t) == 'string' then
		return "'"..t.."'"
	elseif type(t) ~= 'table' then
		return tostring(t)
	end
	local str = '{'
	for k,v in pairs(t) do
		str = str..' '..k..':'..info(v)..', '
	end
	return str..'}'
end

BUFFER = {''}
FLUSH = true
function print(msg, buf)
	buf = buf or BUFFER
	if FLUSH then
		buf[1] = ''
		FLUSH = false
	end
	buf[1] = buf[1]..'['..msg..'] '
end

function persistent_message()
	local buf = {''}
	print('Mode: '..Cursor.mode, buf)
	print('State: '..Cursor:read(), buf)
	print('Reps: '..(REPS or '')..REPS_RESET_BIND, buf)
	return buf[1]
end

function flush()
	g.show(persistent_message()..BUFFER[1])
	g.update()
	FLUSH = true
end

-----------------------------------------
-- framework

g = golly()
gp = require 'gplus'
STATE_COUNT = g.numstates()

QUIT = false
function quit()
	QUIT = true
	Cursor:finish()
	g.select({})
end

function statestr(state)
	local msd = state > 24 and string.char((state - 1) / 24 + 111) or ''
	local lsd = string.char((state - 1) % 24 + 65)
	return msd..lsd
end

function mouse_pos()
	local x, y = gp.split(g.getxy())
	return {
		x = tonumber(x),
		y = tonumber(y),
	}
end

function zoom(exponent)
	g.setmag(g.getmag() + exponent)
end

function pan(dx, dy)
	x, y = gp.getposint()
	gp.setposint(x+dx, y+dy)
end

local function modifiers(str)
	return {
		alt = str:find('alt') ~= nil,
		ctrl = str:find('ctrl') or str:find('cmd') ~= nil,
		shift = str:find('shift') ~= nil,
		-- cmd = str:find('cmd') ~= nil,
	}
end

-- unused
local function bind(key, mods)
	local bind = ''
	for k,v in pairs(mods) do
		if v then bind = bind..k..' ' end
	end
	return bind..key
end

local function handle_event(handler)
	local event = g.getevent()
	if event == '' then return false end
	local type, a, b, c, d = gp.split(event)

	local func = handler[type]
	if func then
		local args
		if type == 'key' then
			args = {a, modifiers(b)}
		elseif type == 'kup' then
			args = {a}
		elseif type == 'click' then
			args = {tonumber(a), tonumber(b), c, modifiers(d)}
		elseif type == 'mup' then
			args = {a}
		else
			g.note('Event type '..type..' is not supported.')
		end
		func(table.unpack(args))
	else
		g.doevent(event)
	end
	return true
end

-----------------------------------------
-- Cursor

Cursor = {
	anchor = {1, 1},
	head = {1, 1},
	hold = 1,
	mode = 'edit',
	data = nil,
}

function Cursor:read()
	return g.getcell(self.head[1], self.head[2])
end

function Cursor:write(cell)
	g.setcell(self.head[1], self.head[2], cell)
end

function Cursor:swap()
	local tmp = self:read()
	self:write(self.hold)
	self.hold = tmp
end

function Cursor:move_point(p, x, y)
	if p == 'head' then self:swap() end
	self[p][1] = x
	self[p][2] = y
	if p == 'head' then self:swap() end
	self:update()
end

function Cursor:update()
	local x = {self.anchor[1], self.head[1]}
	local y = {self.anchor[2], self.head[2]}
	table.sort(x)
	table.sort(y)
	g.select({
		x[1],
		y[1],
		x[2]-x[1] + 1,
		y[2]-y[1] + 1,
	})
end

function Cursor:push_motion(dx, dy)
	self:move_by(dx + 1, dy)
	table.insert(self.data, {-dx, -dy})
end

function Cursor:pop_motion()
	return table.remove(self.data)
end

-- public

function Cursor:toggletext()
	if self.mode == 'edit' then
		self.mode = 'text'
		self.data = {}
		self:move_point('anchor', self.head[1] + 2, self.head[2] + 4)
		if self:read() == 0 then
			self:write(1)
		end
	else
		self.mode = 'edit'
		self.data = nil
		self:move_point('anchor', table.unpack(self.head))
	end
	self:update()
end

function Cursor:clear()
	self:swap()
	g.clear(0)
	self:swap()
end

function Cursor:copy()
	self:swap()
	g.copy()
	self:swap()
end

function Cursor:paste(mode)
	self:swap()
	local x, y, w, h = table.unpack(g.getselrect())
	g.paste(x, y, mode or 'or')
	self:swap()
end

function Cursor:rotate(mods)
	self:swap()
	local x, y, w, h = table.unpack(g.getselrect())
	g.rotate(Binds:special(mods) and 1 or 0)
	if Binds:anchor(mods) then
		g.select({x, y, w, h})
	else
		-- TODO: rotate the cursor within the selection
	end
	self:swap()
end

function Cursor:flip(mods)
	self:swap()
	g.flip(Binds:special(mods) and 1 or 0)
	self:swap()
end

function Cursor:finish()
	self:swap()
end

function Cursor:change_state(amount)
	local state = self:read() + amount
	state = state % STATE_COUNT
	self:write(state)
end

function Cursor:set_state(state)
	state = (state or 0) % STATE_COUNT
	self:write(state)
end

-- do not be confused.
-- the real cell is the one in hold.
-- the cursor state is the one on the grid.
function Cursor:pick()
	self:write(self.hold)
end

function Cursor:place()
	self.hold = self:read()
end

function Cursor:move_point_by(p, dx, dy)
	self:move_point(
		p,
		self[p][1] + dx,
		self[p][2] + dy
	)
end

function Cursor:move_by(dx, dy, mods)
	mods = mods or {}
	pan(dx, dy)
	if Binds:pan(mods) then return end
	if not Binds:anchor(mods) then
		self:move_point_by('anchor', dx, dy)
	end
	self:move_point_by('head', dx, dy)
end

function Cursor:type(rle, w)
	w = w or 3
	local header = 'x = '..w..', y = 5, rule = '..g.getrule()..'\n'
	rle = string.gsub(rle, 'A', statestr(self:read()))
	rle = header..rle..'!'
	g.setclipstr(rle)

	self:paste('copy')
	self:push_motion(w, 0)
end

function Cursor:backspace()
	local delta = self:pop_motion() or {-3, 0}
	self:move_by(delta[1] - 1, delta[2])
	if delta[2] ~= 0 then return end
	self:move_point_by('anchor', 2 - delta[1], 0)
	self:clear()
	self:move_point_by('anchor', delta[1] - 2, 0)
end

function Cursor:crlf()
	local cr = 0
	for i = #self.data, 1, -1 do
		delta = self.data[i]
		if delta[2] ~= 0 then break end
		cr = cr + delta[1] - 1
	end
	self:push_motion(cr - 1, 6)
end

-----------------------------------------
-- Repetitions

REPS = nil
function reps_try_push(key)
	if key == REPS_RESET_BIND then
		REPS = nil
	elseif gp.validint(key) then
		REPS = (REPS or 0) * 10 + tonumber(key)
	else
		return false
	end
	return true
end

function reps_pop()
	REPS = (REPS or 0) // 10
	if REPS == 0 then REPS = nil end
end

MOVE = 0
DURING_MOVE = 1
AFTER_MOVE = 2
CANCEL = 3
RESET = 4

Binds.triggers = {
	[DURING_MOVE] = {},
	[AFTER_MOVE] = {},
}

function Binds:trigger(category)
	for k,v in pairs(self.triggers[category]) do
		Cursor:handle(k, v)
	end
end

function Binds:remove(key)
	for k,v in pairs(self.triggers) do
		v[key] = nil
	end
end

-- TODO: add an event listener to 'key' that just puts
-- pan, special, anchor, and escape into Binds as nil/true
-- then fix every case of mods appearing

function Binds:pan(mods)
	if not mods[self.common.special_mod] then
		return false
	end
	for k,v in pairs(self.triggers) do
		for k,v in pairs(v) do
			return false
		end
	end
	return true
end

function Binds:special(mods)
	return mods[self.common.special_mod]
end

function Binds:anchor(mods)
	return mods[self.common.anchor_mod]
end

function Binds:escape(mods)
	return mods[self.text.escape_mod]
end

function Cursor:run(key, fn, mods)
	local category = fn(mods)
	local triggers = Binds.triggers[category]
	if triggers then
		local m = {} -- shallow copy the mods
		for k,v in pairs(mods) do m[k] = v end
		triggers[key] = m
	elseif category == RESET then
		REPS = nil
	end

	if (category or MOVE) ~= MOVE then return end

	Binds:trigger(DURING_MOVE)
	for i = 2, REPS or 1 do
		fn(mods)
		Binds:trigger(DURING_MOVE)
	end
	Binds:trigger(AFTER_MOVE)
end

-----------------------------------------
-- main

Cursor:move_point('anchor', gp.getposint())
Cursor:move_point('head', gp.getposint())

-----------------------------------------
-- event handling

function Cursor:move_input(dx, dy, mods)
	if self.mode == 'text' then
		dx = dx * 4
		dy = dy * 6
		if not Binds:pan(mods) then
			self.data = {}
		end
	end
	self:move_by(dx, dy, mods)
end

function Cursor:text(key, mods)
	mods = mods or {}
	local escape = Binds:escape(mods)
	if escape and reps_try_push(key) then return end

	local switch = escape and Binds.text or font
	local item = switch[key]
	local ty = type(item)
	if ty == 'function' then
		self:run(key, item, mods)
	elseif ty == 'table' then
		fn = function() self:type(table.unpack(item)) end
		self:run(key, fn, mods)
	elseif mods.shift then
		mods.shift = nil
		self:text(key, mods)
	else
		print('unknown text keybind: '..tostring(key))
	end
end

function Cursor:edit(key, mods)
	if reps_try_push(key) then return end

	local fn = Binds.edit[key]
	if fn then
		self:run(key, fn, mods)
	else
		print('unknown edit keybind: '..tostring(key))
	end
end

function Cursor:handle(key, mods)
	self[self.mode](self, key, mods)
end

local handler = {
	key = function(key, mods)
		Cursor:handle(key, mods)
	end,
	kup = function(key)
		Binds:remove(key)
	end,
}
-- local function tick(delta) end

RECENT = 10
IDLE = 300
IDLE_TIMEOUT = 1000 -- ms

local idle_countdown = IDLE_TIMEOUT
local is_idle = true
repeat
	if handle_event(handler) then
		idle_countdown = IDLE_TIMEOUT
		if is_idle then
			print('Tickrate back to normal.')
		end
		is_idle = false
	elseif idle_countdown > 0 then
		idle_countdown = idle_countdown - RECENT
		is_idle = false
	else
		if not is_idle then
			print('Idle. Reducing tickrate.')
		end
		is_idle = true
	end
	-- tick(wait)
	flush()
	FLUSH = true
	g.update()
	g.sleep(is_idle and IDLE or RECENT)
until QUIT
g.show('[Quit kbe.lua.]')
g.update()

----------------------------------------------------------------------------------
-- wow you've reached the end of this trip
