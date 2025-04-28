local g = golly()

local skip_construct = false
local skip_destruct = false

local curlayer = g.getlayer()
local newindex = g.duplicate()

local cells = g.getcells(g.getrect())

local cells2 = {}

local new_top = 0
local new_left = 0
local new_bottom = 0
local new_right = 0
local new_tape_top = 0
local new_tape_left = 0

local old_top = 0
local old_left = 0
local old_bottom = 0
local old_right = 0
local old_tape_top = 0
local old_tape_left = 0

local old_destructor_x = 0
local old_destructor_y = 0

local tunnel_x = 0
local tunnel_y = 0

for i=1,#cells-2,3 do
 local cell = {cells[i], cells[i+1], cells[i+2]}
 cells2[#cells2+1] = cell
 if cell[3]>0 and cell[3]<=8 then
  g.setcell(cell[1], cell[2], 0)
 end
 if cell[3]==1 then
  new_left = cell[1]+1
  new_top = cell[2]+1
 end
 if cell[3]==2 then
  new_right = cell[1]-1
  new_bottom = cell[2]-1
 end
 if cell[3]==3 then
  new_tape_left = cell[1]
  new_tape_top = cell[2]
 end
 if cell[3]==4 then
  old_left = cell[1]+1
  old_top = cell[2]+1
 end
 if cell[3]==5 then
  old_right = cell[1]-1
  old_bottom = cell[2]-1
 end
 if cell[3]==6 then
  old_tape_left = cell[1]
  old_tape_top = cell[2]
 end
 if cell[3]==7 then
  old_destructor_x = cell[1]
  old_destructor_y = cell[2]
  g.setcell(cell[1], cell[2], 11)
 end
 if cell[3]==8 then
  tunnel_x = cell[1]
  tunnel_y = cell[2]
 end
end

for i=0,new_bottom-new_top-4 do
 g.setcell(old_destructor_x - 1, old_destructor_y, 12)
 g.setcell(old_destructor_x, old_destructor_y + 1, 20)
 if old_destructor_x == tunnel_x and old_destructor_y + 1 == tunnel_y then
  g.setcell(old_destructor_x, old_destructor_y + 1, 11)
 end
 old_destructor_y = old_destructor_y + 1
end

for i=0,new_right-new_left+2 do
 g.setcell(old_destructor_x - 1, old_destructor_y, 11)
 g.setcell(old_destructor_x, old_destructor_y + 1, 19)
 old_destructor_x = old_destructor_x - 1
end

for i=0,new_bottom-new_top+2 do
 g.setcell(old_destructor_x - 1, old_destructor_y, 12)
 g.setcell(old_destructor_x, old_destructor_y + 1, 20)
 old_destructor_y = old_destructor_y + 1
end

g.setcell(old_destructor_x - 1, old_destructor_y, 12)
g.setcell(old_destructor_x - 1, old_destructor_y + 1, 9)

for i=0,new_tape_left-new_left-2 do
 g.setcell(old_destructor_x, old_destructor_y, 17)
 g.setcell(old_destructor_x, old_destructor_y + 1, 9)
 old_destructor_x = old_destructor_x + 1
end

g.setcell(old_destructor_x, old_destructor_y, 20)
g.setcell(old_destructor_x, old_destructor_y + 1, 10)

local rows = {}
local row_lefts = {}
local row_rights = {}

for i=1,#cells2 do
 local x = cells2[i][1]
 local y = cells2[i][2]
 if x >= new_left and x <= new_right and y >= new_top and y <= new_bottom then
  if rows[y] == nil then
   rows[y] = {}
   row_lefts[y] = x
   row_rights[y] = x
  end
  rows[y][x] = cells2[i][3]
  if row_lefts[y] >= x then row_lefts[y] = x end
  if row_rights[y] <= x then row_rights[y] = x end
 end
end

local old_cols = {}
local old_col_tops = {}
local old_col_bottoms = {}

for i=1,#cells2 do
 local x = cells2[i][1]
 local y = cells2[i][2]
 if x >= old_left and x <= old_right and y >= old_top and y <= old_bottom then
  if old_cols[x] == nil then
   old_cols[x] = {}
   old_col_tops[x] = y
   old_col_bottoms[x] = y
  end
  old_cols[x][y] = cells2[i][3]
  if old_col_tops[x] >= y then old_col_tops[x] = y end
  if old_col_bottoms[x] <= y then old_col_bottoms[x] = y end
 end
end

local c_init = {1,1,1,1,1,0,1,0,1,1,1,0,1,1,0,1,1,1,0,1,0,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,1,1,0,0,0}
local c_up = {1,1,1,1,1,0,1,0,0,1,0,0,0,1,1,1,1,1,0,1,1,0,0,1,0,1,1,0,1,1,1,0,1,1,0,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,1,1,0,0,0}
local c_start_fastright = {1,1,1,1,1,0,1,1,1,0,1,0,0,0,1,1,1,1,1,0,0,0}
local c_fastright = {1,1,1,1,1,0,1,0,1,1,0,0,0}
local c_end_fastright = {1,1,1,0,1,0,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,1,1,0,0,0}
local c_left = {1,1,1,1,1,0,1,0,0,1,0,1,0,1,1,1,1,1,0,1,1,1,0,1,1,0,1,1,1,0,0,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,1,1,0,0,0}
local c_down = {1,1,1,1,1,0,1,1,1,0,1,1,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,0,0,1,0,1,1,1,1,1,0,1,1,0,1,1,1,1,0,0,0,1,0,1,0,1,1,1,1,1,0,1,0,1,1,0,0,0}
local c_finalize = {1,0,1,1,0,1,1,1,0,0,0}
local constructions = {[9] = {1,0,0,0,0}, [10] = {1,0,0,0,1,0,0,0}, [11] = {1,0,0,1,0,0,0}, [12] = {1,0,1,0,0,0}, [17] = {1,0,1,1,0,0,0}, [18] = {1,1,0,0,0}, [19] = {1,1,0,1,0,0,0}, [20] = {1,1,1,0,0,0}, [25] = {1,1,1,1,0,0,0}}

local tape = {}
tape[#tape+1]=c_init
for y=new_top,new_bottom do tape[#tape+1]=c_up end
for y=new_top,new_bottom do
 tape[#tape+1]=c_start_fastright
 for x=new_left,row_rights[y] do tape[#tape+1]=c_fastright end
 tape[#tape+1]=c_end_fastright
 for x=row_rights[y],new_left,-1 do
  tape[#tape+1]=c_left
  tape[#tape+1]=constructions[rows[y][x]]
 end
 tape[#tape+1]=c_down
end

tape[#tape+1]=c_start_fastright
for i=new_left,new_tape_left-3 do tape[#tape+1]=c_fastright end
tape[#tape+1]=c_finalize

if skip_construct then
 tape = {{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}}
end

local d_init = {1,1,1,1,1,1,0,1,0,0,1,1,0,1,0}
local d_down = {1,0,0,0,0,1,0,1,0,1,0,1,1,1,1,1,0,1,0,0,0,0,1,0,0,0,1,1,1,1,0,0,0,0,1,1,0,1,0,0,1,1,1,1,1,0,1,1,1,1,1,0}
local d_left = {1,1,0,0,0,1,0,0,0,1,1,1,1,1,0,1,0,0,1,1,0,1,0,1,0,0,0,0,1,1,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0}
local d_right = {1,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,1,1,0,1,0,0,0,1,1,1,1,1,0,1,1,0,1,0,1,1,1,0,1,0,1,0,0,0,1,1,1,1,1,0}
local d_up = {1,0,0,0,0,1,1,0,0,0,1,1,1,1,0,1,0,0,0,0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,0,0,0,0,1,1,1,1,0,0,1,1,1,0,1,0,1,1,1,1,1,0,1,1,1,1,1,0}
local d_retract = {1,1,1,1,1,0,1,1,0,1,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,0,0,0,1,1,1,0,0,0,0,1,0,1,1,1,0,0,0,0,0,1,1,1,1,1,0}
local d_retract_turn = {1,1,1,1,1,0,1,1,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0}
local d_modify = {1,0,0,0,0,1,0,1,1,1,1,0,1,1,0,1,1,1,1,0,1,1,0,0,1,1,0,1,0,0,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,0,1,1,0,0,0,0,1,1,0,0,0,1,0,1,1,1,0,0,0,0,1,1,1,0,0,0,1,1,1,1,1,0,1,1,1,1,1,0,1,1,1,0,1,0,0,0,1,1,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,0}
--local d_meld = {1,0,0,0,0,1,1,0,1,0,1,1,1,1,0,1,1,0,1,0,0,1,1,1,1,1,0,1,0,0,0,0,0,1,1,1,1,1,0,1,1,1,1,1,0,0,1,1,1,1,1,0,1,0,1,0,0,1,1,1,1,1,0}
local d_meld = {1,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,1,1,1,1,0,0,1,1,1,1,1,0,1,0,1,0,0,0,1,1,1,1,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,0}
local d_finalize = {1,0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,0,1,1,1,1,1,0,0,1,1,1,1,1,0,1,0,1,0,1,0,0,0,1,1,1,1,1,0,1,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,1,1,0,0,1,1,1,0,1,1,0,0,0,1,1,1,0,0,0,1,0,1,1,1,1,1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,1,0}
local destruct_normal = {1,1,1,0,0,1,0,0,0,1,1,1,1,1,0}
local destruct_special = {1,0,1,0,1,0,0,0,0,0,1,1,1,1,1,0}

tape[#tape+1] = d_init
tape[#tape+1] = d_left
for i=new_top,old_top-3 do
 tape[#tape+1] = d_down
end
tape[#tape+1] = d_modify
tape[#tape+1] = d_up
tape[#tape+1] = d_up
for x=old_right,old_left,-1 do
 tape[#tape+1] = d_left
 if not skip_destruct then
  for y=old_top,old_col_bottoms[x] do
   if old_cols[x][y] and old_cols[x][y] >= 17 and old_cols[x][y] <= 20 then tape[#tape+1] = destruct_special
   else if old_cols[x][y] then tape[#tape+1] = destruct_normal end end
   tape[#tape+1] = d_down
  end
  for y=old_top,old_col_bottoms[x] do
   tape[#tape+1] = d_up
  end
 end
end
tape[#tape+1] = d_left
tape[#tape+1] = d_left
--for y=old_top,old_bottom+1 do
-- tape[#tape+1] = d_down
--end
tape[#tape+1] = d_down
tape[#tape+1] = d_meld
for i=0,new_tape_left-new_left-2 do
 tape[#tape+1] = d_retract
end
tape[#tape+1] = d_retract_turn
for i=0,new_bottom-new_top+2 do
 tape[#tape+1] = d_up
end
for i=0,new_right-new_left+2 do
 tape[#tape+1] = d_right
end
tape[#tape+1] = d_down
tape[#tape+1] = d_down
tape[#tape+1] = d_finalize

--tape = {{1,0,1,1,0,1,1,1,0,1,1,1,1,0}}

local tape2 = {}
for i=1,#tape do
 for j=1,#tape[i] do
  tape2[#tape2+1] = tape[i][j]
 end
end

if #tape2%2 == 0 then
 tape2[#tape2+1]=0
end

g.setcell(new_tape_left, new_tape_top, 25 + tape2[1] * 2 + tape2[2])
g.setcell(old_tape_left, old_tape_top, 25)
for i=3,(#tape2+1)//2 do
 g.setcell(new_tape_left + i - 2, new_tape_top, 11+tape2[i]*4)
 g.setcell(old_tape_left + i - 2, old_tape_top, 11)
end
g.setcell(new_tape_left + (#tape2+3)//2 - 3, new_tape_top + 1, 10+tape2[(#tape2+3)//2]*4)
g.setcell(old_tape_left + (#tape2+3)//2 - 3, old_tape_top + 1, 10)
for i=(#tape2+5)//2,#tape2 do
 g.setcell(new_tape_left + (#tape2+3)//2 - 3 - (i - (#tape2+3)//2), new_tape_top + 1, 9+tape2[i]*4)
 g.setcell(old_tape_left + (#tape2+3)//2 - 3 - (i - (#tape2+3)//2), old_tape_top + 1, 9)
end
g.setcell(old_tape_left + (#tape2+3)//2 - 3 - (#tape2 - (#tape2+3)//2), old_tape_top + 1, 0)

g.show(string.format("Tape length %d, period ~%d", #tape2, #tape2*(1+3+14)))