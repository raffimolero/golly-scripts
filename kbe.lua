----------------------------------------
-- globals

local g = golly()
local gp = require 'gplus'
local STATE_COUNT = g.numstates()

local HELD = {}
local FINISHED = false

local REPS = nil
local Cursor = {
	anchor = {1, 1},
	head = {1, 1},
	hold = 0,
	mode = 'normal',
	data = nil,
}

local function quit()
	FINISHED = true
	Cursor:finish()
	g.select({})
end

-----------------------------------------
-- keybinds

local normalbinds = {
	[':'] = quit,
	i = function(self) self:toggletext() end,

	k = function(self, mods) self:move_by(0, -1, mods) end,
	j = function(self, mods) self:move_by(0, 1, mods)  end,
	h = function(self, mods) self:move_by(-1, 0, mods) end,
	l = function(self, mods) self:move_by(1, 0, mods)  end,

	q = function(self) self:change_state(-1) end,
	e = function(self) self:change_state(1) end,

	r = function(self) self:pick() end,
	f = function(self) self:place() end,
	x = function(self) self:clear() end,
	c = function(self) self:copy() end,
	v = function(self) self:paste() end,
}

local textbinds = {
	['return'] = function(self) self:toggletext() end,

	k = function(self) self.data = {} self:move_by(0, -6) end,
	j = function(self) self.data = {} self:move_by(0, 6)  end,
	h = function(self) self.data = {} self:move_by(-4, 0) end,
	l = function(self) self.data = {} self:move_by(4, 0)  end,

	q = function(self) self:change_state(-1) end,
	e = function(self) self:change_state(1) end,

	x = function(self) self:clear() end,
	c = function(self) self:copy() end,
	v = function(self) self:paste() end,
}

local textfont = {
	['return'] = function(self) self:crlf() end,
	delete = function(self) self:backspace() end,

	space = {'', 1},
	tab = {'', 7},

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
-- util

local function map(f, arr)
	local out = {}
	for _,v in ipairs(arr) do
		table.insert(out, f(v))
	end
end

local function find(arr, val)
	for i,v in ipairs(arr) do
		if v == val then
			return i
		end
	end
	return nil
end

local function dbg(t)
	if type(t) ~= 'table' then
		return tostring(t)
	end
	local str = '{'
	for k,v in pairs(t) do
		str = str..' '..k..':'..dbg(v)..', '
	end
	return str..'}'
end

-----------------------------------------
-- framework

function statestr(state)
	local msd = state > 24 and string.char((state - 1) / 24 + 111) or ''
	local lsd = string.char((state - 1) % 24 + 65)
	return msd..lsd
end

local function mouse_pos()
	local x, y = gp.split(g.getxy())
	return {
		x = tonumber(x),
		y = tonumber(y),
	}
end

local function modifiers(str)
	return {
		alt = str:find('alt') ~= nil,
		ctrl = str:find('ctrl') or str:find('cmd') ~= nil,
		shift = str:find('shift') ~= nil,
		-- cmd = str:find('cmd') ~= nil,
	}
end

local function bind(key, mods)
	local bind = ''
	for k,v in pairs(mods) do
		if v then bind = bind..k..' ' end
	end
	return bind..key
end

local function handle_event(handler)
	local event = g.getevent()
	if event == '' then return end
	local type, a, b, c, d = gp.split(event)

	local func = handler[type]

	if type == 'key' then
		HELD[a] = true
	elseif type == 'kup' then
		HELD[a] = nil
	elseif type == 'click' then
		do return quit() end -- HACK
		HELD['m'..c] = true
	elseif type == 'mup' then
		HELD['m'..a] = nil
	end

	if func then
		local args
		if type == 'key' then
			HELD[a] = true
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
end

-----------------------------------------
-- Cursor

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
	x = {self.anchor[1], self.head[1]}
	y = {self.anchor[2], self.head[2]}
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
	if self.mode == 'normal' then
		self.mode = 'text'
		self.data = {}
		self:move_point('anchor', self.head[1] + 2, self.head[2] + 4)
		if self:read() == 0 then
			self:write(1)
		end
	else
		self.mode = 'normal'
		self.data = nil
		self:text(' ')
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
	x, y, w, h = table.unpack(g.getselrect())
	g.paste(x, y, mode or 'or')
	self:swap()
end

function Cursor:finish()
	self:swap()
end

function Cursor:change_state(by)
	self:swap()
	self.hold = (self.hold + STATE_COUNT + by) % STATE_COUNT
	self:swap()
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
	-- pan
	x, y = gp.getposint()
	gp.setposint(x+dx, y+dy)
	if mods.ctrl then
		return
	end
	if not mods.shift then
		self:move_point_by('anchor', dx, dy)
	end
	self:move_point_by('head', dx, dy)
	if self.mode == 'normal' and HELD.f then self:place() end
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
	g.show(cr)
	self:push_motion(cr - 1, 6)
end

-----------------------------------------
-- macros



-----------------------------------------
-- main

Cursor:move_point('anchor', gp.getposint())
Cursor:move_point('head', gp.getposint())

-----------------------------------------
-- event handling

function Cursor:text(key, mods)
	mods = mods or {}
	local switch = mods.shift and textbinds or textfont
	local item = switch[key]
	local ty = type(item)
	if ty == 'function' then
		item(self)
	elseif ty == 'table' then
		Cursor:type(table.unpack(item))
	elseif mods.shift then
		mods.shift = nil
		self:text(key, mods)
	else
		g.show('unknown keybind: '..tostring(key))
	end
end

function Cursor:normal(key, mods)
	-- g.show(dbg(key))
	-- do return end

	if gp.validint(key) then
		REPS = (REPS or 0) * 10 + tonumber(key)
		g.show(REPS)
	else
		if key == ';' then
			REPS = self.data.reps
			key = self.data.key
			mods = self.data.mods
		end

		local fn = normalbinds[key]
		if fn then
			for i = 1, REPS or 1 do fn(self, mods) end
			self.data = {
				reps = REPS,
				key = key,
				mods = mods,
			}
			g.show('')
		else
			g.show('unknown keybind: '..tostring(key))
		end
		REPS = nil
	end 
end

function Cursor:handle(key, mods)
	self[self.mode](self, key, mods)
end


local handler = { key = function(key, mods) Cursor:handle(key, mods) end }
local function tick() end

repeat
	handle_event(handler)
	-- tick()
	g.update()
until FINISHED

-----------------------------------------
