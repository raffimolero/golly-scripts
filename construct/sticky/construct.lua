local g = golly()
local gp = require "gplus"

local r = gp.rect(g.getselrect())
if r.empty then g.exit("There is no selection.") end

-- local t1 = os.clock()

local oldsecs = os.clock()
local maxstate = g.numstates() - 1

local tape = "r"

for row = r.top, r.bottom do
    tape = tape .. "u"
end

local armcol = r.left

for row = r.bottom, r.top, -1 do
    -- if large selection then give some indication of progress
    local newsecs = os.clock()
    if newsecs - oldsecs >= 1.0 then
        oldsecs = newsecs
        g.update()
    end
end

for row = r.top, r.bottom do
    for col = r.right, r.left, -1 do
        if g.getcell(col, row) == 1 then 
          if armcol < col then
            for i = armcol, col-1 do
              tape = tape .. "r"
            end
          else
            for i = col, armcol-1 do
              tape = tape .. "l"
            end
          end
          tape = tape .. "f"
          armcol = col
        end
    end
    tape = tape .. "d"
end

for i = r.left, armcol-1 do
  tape = tape .. "l"
end
tape = tape .. "l"

tape = g.getstring("Edit the tape:", tape, "Sticky Constructor Tape Maker")

local x = r.left - 10
local y = r.bottom + 10
g.setcell(x, y, 3)
g.setcell(x,y+1,2)
g.show(tape)
for i = 1, string.len(tape) do
  if string.sub(tape, i, i) == "r" then y = y + 3 end
  if string.sub(tape, i, i) == "l" then y = y + 5 end
  if string.sub(tape, i, i) == "f" then y = y + 7 end
  if string.sub(tape, i, i) == "u" then y = y + 9 end
  if string.sub(tape, i, i) == "d" then y = y +11 end
  g.setcell(x, y, 3)
  g.setcell(x,y+1,2)
end

if not r.visible() then g.fitsel() end

-- g.show(""..(os.clock()-t1))
