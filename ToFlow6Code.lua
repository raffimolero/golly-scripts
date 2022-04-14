local g = golly()

local rect = g.getselrect()
if #rect == 0 then g.exit("Select something to print.") end

local patt = g.getcells(rect)
local rle = 'x = 0, y = 0, rule = Flow6\n2A$A$A$A$'

clip = ""
function log(val)
	clip = clip .. tostring(val) .. "\n"
end

function to_string( tbl )
    if  "nil"       == type( tbl ) then
        return tostring(nil)
    elseif  "table" == type( tbl ) then
        return table_print(tbl)
    elseif  "string" == type( tbl ) then
        return tbl
    else
        return tostring(tbl)
    end
end


local function parseCells(cells)

end

local function getLines(cells)
	local lines = {}

	local row = 0
	local line = 0
	local len = 0
	local cell

	local switch = {
		function(val) x = val end,
		function(val) y = val end,
		function(s)
			len = x
		end
	}

	for idx, x in next, cells do
		switch[len % 3 + 1](val)
		len = len + 1
	end
end

	-- local lines = {}
	-- for y = 0, rect[3], 1
	-- 	local line = {}
	-- 	for x = 0, rect[4], 1
	-- 		local c = g.getcell(x + rect[2], y + rect[1])
	-- 		if c ~= 0 then line.length = x end
	-- 		table.insert(line, c)

getLines(patt)
g.setclipstr(clip)
