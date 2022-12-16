import golly as g
p = 2
g.setcell(0,0,1)
g.setcell(0,1,1)
g.setcell(-1,1,1)

def place_cell(c):
    global p
    g.setcell(-p, 1, c)
    p += 1
    
def place_signal(length):
    for _ in range(length):
        place_cell(5)
    place_cell(2)
    place_cell(1)

def cmd(*counts):
    for count in counts:
        place_signal(count)

x, y, w, h = g.getselrect()
for y in range(y, y+h):
    cmd(3)
    for z in range(w):
        cmd(1)
    for x in range(x+w-1, x-1, -1):
        cmd(2)
        if g.getcell(x, y) == 0:
            cmd(1, 2)
    cmd(2, 3, 2, 1)