-- Palette, table artwork, camera, particles and menus. No scoring here.
function center(s,y,c)
 print(s,64-#s*2,y,c)
end

function label(s,x,y,c)
 print(s,x+1,y+1,0) print(s,x,y,c)
end

function number(n)
 if n==0 then return "000000" end
 local s=tostr(flr(n)).."00"
 while #s<6 do s="0"..s end
 return s
end

function actor(id,frame,x,y,flip,scale)
 local row=id*24
 local size=24
 if id==3 then row=80 size=32 end
 sspr(frame*size,row,size,size,x,y,size*(scale or 1),size*(scale or 1),flip)
end

function rail(x1,y1,x2,y2,c)
 for i=-2,2 do line(x1+i,y1,x2+i,y2,0) end
 line(x1,y1+1,x2,y2+1,4)
 line(x1,y1,x2,y2,c or 9)
end

function lamp(x,y,c,on)
 circfill(x,y,3,0) circ(x,y,3,4)
 circfill(x,y,1,on and c or 5)
 if on then pset(x,y-1,7) end
end

function arrow(x,y,c)
 line(x,y,x-3,y+4,c) line(x,y,x+3,y+4,c)
 line(x,y+1,x,y+7,c)
end

function pine(x,y,h,c)
 line(x,y,x,y+h,5)
 for j=0,h-3 do
  local w=flr(j/4)+1-flr((j%8)/3)
  line(x-w,y+j,x+w,y+j,c)
 end
end

function backdrop()
 rectfill(0,0,127,224,0)
 -- Velvet playfield, gold inlay, hand-etched woodland.
 rectfill(9,21,111,205,1)
 ovalfill(9,8,112,63,1)
 fillp(0xa5a5) rectfill(13,35,107,185,0) fillp()
 for y=20,201,8 do
  for x=14,107,8 do
   line(x,y-1,x+1,y,1) line(x+1,y,x,y+1,1)
  end
 end
 for y=34,174,18 do
  pine(14,y,13,3) pine(106,y+5,13,3)
  pset(12,y-2,11) pset(108,y+2,11)
 end
 for w in all(walls) do rail(w[1],w[2],w[3],w[4],9) end
 -- Inner orbit, riveted shooter channel.
 line(14,49,14,133,5) line(108,49,108,133,5)
 for y=57,201,12 do pset(115,y,5) pset(121,y,13) end
 for y=22,182,20 do
  circfill(5,y,2,4) pset(5,y-1,10)
  circfill(126,y,2,4) pset(126,y-1,10)
 end
 for i=1,3 do
  local x=38+(i-1)*24
  line(x-10,21,x-10,39,13)
  lamp(x,30,10,false)
  label(sub("red",i,i),x-1,20,6)
 end
 -- Moon above the orbit.
 circfill(62,15,6,13) circfill(65,13,5,1)
 pset(60,13,7)
 -- Center medallion / engraved crimson hood.
 oval(33,98,91,157,3) oval(36,100,88,154,5)
 line(62,98,91,128,3) line(91,128,62,157,3)
 line(62,157,33,128,3) line(33,128,62,98,3)
 label("r e d",53,155,14)
 -- Brass filigree and little enamel stars.
 for i=0,7 do
  local a=i/8
  local x,y=62+cos(a)*27,128+sin(a)*29
  pset(x,y,9)
 end
 for i=0,1 do
  local x=i==0 and 28 or 96
  line(x,72,x,89,4) line(x-2,79,x+2,79,9)
  pset(x,77,10) pset(x,84,9)
 end
 -- Cottage and moon well.
 for i=1,2 do
  local x=i==1 and 24 or 100
  circfill(x,110,8,0) circ(x,110,8,13)
  circ(x,110,5,5)
 end
 line(16,102,24,96,9) line(24,96,32,102,9)
 rect(19,101,29,105,4)
 pset(22,103,10) pset(26,103,10)
 circfill(100,99,4,12) circfill(102,97,3,1)
 -- Slingshots and inlane arrows.
 for i=1,2 do
  local x=i==1 and 30 or 94
  local d=i==1 and 1 or -1
  for j=0,7 do line(x,163+j*2,x+d*j,177+j,2) end
  rail(x,163,x+d*12,180,14)
  rail(x,163,x-d*4,181,8)
  line(x-d*4,181,x+d*12,180,4)
  arrow(x-d*10,166,12)
  lamp(x-d*7,190,11,false)
 end
 label("lantern",48,171,5)
 label("wood",54,178,13)
 for y=206,218,3 do line(42,y,82,y,2) end
 label("midnight",46,210,8)
end

-- Pre-render the intricate 128x256 table into spare RAM once. Scrolling is
-- one contiguous framebuffer copy; the frame budget goes to ball physics.
function cache_table()
 clip() camera() backdrop() memcpy(0x8000,0x6000,8192)
 camera(0,128) backdrop() memcpy(0xa000,0x6000,8192)
 camera()
end

function draw_table()
 memcpy(0x6000,0x8000+view_y*64,8192)
 for i=1,3 do
  local x=38+(i-1)*24
  lamp(x,30,10,g.red[i])
  label(sub("red",i,i),x-1,20,g.red[i] and 10 or 6)
 end
 for i=1,2 do
  local x=i==1 and 24 or 100
  local lit=i==1 and g.phase==2 or i==2 and #balls>1
  if lit then
   circ(x,110,8,12) circ(x,110,5,7)
   arrow(x,94+sin(tick/40),12)
  end
  lamp(i==1 and 23 or 101,190,11,g.save>0)
 end
 actor(0,flr(tick/18)%4,50,131)
 local frame=flr(tick/16)%4
 -- Character guardians react to their mission.
 if g.phase==3 then
  actor(3,flr(tick/20)%2,47,39)
  for i=1,g.boss do pset(48+i*2,76,8) end
 else
  actor(2,frame,50,42)
 end
 actor(1,frame,12,76)
 for p in all(bumpers) do
  local c=p.flash>0 and 7 or (g.phase==3 and 8 or 12)
  circfill(p.x+1,p.y+3,10,0)
  circfill(p.x,p.y,9,5) circ(p.x,p.y,9,13)
  circfill(p.x,p.y,7,1) circ(p.x,p.y,7,c)
  circfill(p.x,p.y,4,p.flash>0 and 10 or 3)
  line(p.x-2,p.y,p.x+2,p.y,c) line(p.x,p.y-2,p.x,p.y+2,c)
  pset(p.x-3,p.y-5,7)
  if p.flash>0 then circ(p.x,p.y,10+(12-p.flash)/2,c) end
 end
 for i,t in ipairs(targets) do
  rectfill(t.x-5,t.y-2,t.x+5,t.y+3,0)
  rect(t.x-4,t.y-1,t.x+4,t.y+2,t.flash>0 and 7 or 9)
  line(t.x-3,t.y,t.x+3,t.y,t.on and 10 or 4)
  lamp(t.x,t.y-8,10,t.on)
 end
 for f in all(flippers) do
  local x,y=f.x+f.side*cos(f.a)*19,f.y-sin(f.a)*19
  for j=-2,2 do line(f.x,f.y+j+1,x,y+j+1,0) end
  for j=-1,1 do line(f.x,f.y+j,x,y+j,f.active and 14 or 8) end
  line(f.x,f.y-2,x,y-2,f.active and 7 or 15)
  circfill(f.x,f.y,3,2) circ(f.x,f.y,3,14) pset(f.x,f.y-1,7)
 end
 if g.ready then
  local y=197+g.charge*6
  circfill(118,y,2,7) pset(117,y-1,12)
  for j=0,4 do line(115,y+4+j*2,121,y+4+j*2,5) end
  rectfill(115,218-g.charge*20,121,218,10)
 end
 -- Animated orbit chase lamps.
 for i=0,9 do
  local a=i/20+0.01
  local x,y=62+cos(a)*50,48+sin(a)*36
  pset(x,y,(flr(tick/5)%10)==i and 7 or 4)
 end
 for b in all(balls) do
  for i,p in ipairs(b.trail) do
   circfill(p.x,p.y,(i-1)/5,i<4 and 5 or 12)
  end
  circfill(b.x+1,b.y+2,2,0)
  circfill(b.x,b.y,2,6) pset(b.x-1,b.y-1,7) pset(b.x,b.y,7)
 end
 for p in all(particles) do pset(p.x,p.y,p.c) end
 for f in all(floats) do label(f.s,f.x-#f.s*2,f.y,10) end
end

function objective()
 if g.tilt>0 then return "tilt - wait for the table" end
 if g.ready then return "hold x/down - release to shoot" end
 if g.phase==1 then return "wolf bumpers  "..g.hits.."/6" end
 if g.phase==2 then return "rescue grandma: left cottage" end
 return "briar hart  "..g.boss.." hits left"
end

function hud()
 camera() clip()
 rectfill(0,0,127,13,0) line(0,13,127,13,4)
 label(number(g.score),3,2,7)
 label("x"..g.mult,48,2,10)
 label("ball "..min(3,g.ball).."/3",91,2,6)
 local s=objective()
 if message_time>0 then s=message end
 print(s,3,8,g.tilt>0 and 8 or 13)
 rectfill(0,119,127,127,0) line(0,119,127,119,4)
 if g.save>0 and not g.ready then
  print("save "..ceil(g.save/60),3,122,11)
 else print("z nudge",3,122,13) end
 if #balls>1 then print("multiball",48,122,12)
 else print("up:look",48,122,5) end
 print("<  >",108,122,14)
 -- Edge indicators keep offscreen multiballs trackable.
 for b in all(balls) do
  local y=b.y-cam
  if y<16 then arrow(mid(6,b.x,121),16,7) end
  if y>116 then line(b.x-2,114,b.x,117,7) line(b.x,117,b.x+2,114,7) end
 end
end

function forest()
 cls(0)
 for i=0,45 do
  local x=(i*37+11)%128 local y=(i*23)%90
  pset(x,y,(i+flr(tick/45))%7==0 and 7 or 5)
 end
 circfill(91,28,18,13) circfill(97,23,17,1)
 for i=0,8 do pine(i*18-7,25+(i*7)%27,76,1) end
 for i=0,6 do pine(i*25-9,58+(i*13)%30,55,3) end
 ovalfill(-20,95,147,151,1)
 for i=0,30 do
  local x=i*17%128 local y=100+i*7%27
  line(x,y,x+2,y,3)
 end
 for i=1,12 do
  local x=(i*19+tick/12)%128 local y=70+(i*23)%45+sin(tick/180+i)*4
  pset(x,y,i%2==0 and 10 or 12)
 end
end

function title_screen()
 forest()
 -- Tall custom lettering, drawn from the native font at 2x using scratch RAM.
 rectfill(0,0,29,7,0) print("r e d",0,0,8)
 memcpy(0x4300,0x6000,512)
 rectfill(0,0,29,7,0)
 for y=0,5 do
  for x=0,21 do
   local v=peek(0x4300+y*64+flr(x/2))
   local c=x%2==0 and v%16 or flr(v/16)
   if c==8 then rectfill(22+x*4,14+y*4,25+x*4,17+y*4,2)
    rectfill(21+x*4,12+y*4,24+x*4,15+y*4,y<3 and 14 or 8) end
  end
 end
 center("m i d n i g h t",43,15)
 line(18,52,109,52,4) center("p i n b a l l",56,10)
 actor(0,flr(tick/18)%4,24,73,false,1.4)
 actor(2,flr(tick/18)%4,73,73,true,1.4)
 circfill(64,86+sin(tick/90)*5,3,7)
 pset(63,84+sin(tick/90)*5,12)
 rectfill(14,106,113,117,0) rect(14,106,113,117,4)
 center("x play    z field guide",109,flr(tick/35)%2==0 and 15 or 7)
 center("best "..number(best),122,13)
end

function guide_screen()
 cls(1) rect(3,3,124,124,4)
 center("field guide  "..page.."/2",9,10)
 line(12,19,115,19,5)
 if page==1 then
  label("the art of the silver ball",10,26,15)
  print("left / right: flippers\nx/down: hold, then release\n        to launch\nz: nudge (3 fast = tilt!)\nup: see upper playfield\nesc / enter: pause",10,39,6)
  print("flippers shift red lights.\n8 seconds of launch save.\ncatch on a held flipper,\nrelease, then shoot again.",10,84,13)
 else
  print("1. defeat the wolf\n   hit six blue bumpers.\n2. save grandmother\n   shoot the left cottage.\n3. break the briar hart\n   hit bumpers + lanterns.",10,27,6)
  print("red lanes: multiplier up.\n2 sets or 3 moon locks:\nthree-ball multiball!\nright well: 5000 jackpot.\n3 lanterns: ball save.",10,76,13)
 end
 center("<> page   x play   z back",115,14)
end

function results_screen()
 rectfill(9,31,118,101,0) rect(9,31,118,101,9)
 center(g.won>0 and "dawn in lantern wood" or "the forest remembers",39,14)
 center(number(g.score),53,7)
 center("best "..number(best),65,10)
 center("harts "..g.won.."   jackpots "..g.jackpots,77,13)
 center("x again   z title",91,6)
end
