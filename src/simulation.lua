-- RED: MIDNIGHT PINBALL
-- Original table for the RED cast
-- Pure rules/physics. Drawing and input live in main/renderer.
function new_game()
 g={score=0,ball=1,mult=1,round=1,phase=1,hits=0,
  red={false,false,false},sets=0,locks=0,boss=6,
  save=0,heat=0,tilt=0,charge=0,ready=true,wait=0,
  combo=0,combo_time=0,jackpots=0,won=0,skill=0,over=false}
 balls={} particles={} floats={}
 flippers={{x=39,y=191,side=1,a=0.09,old=0.09},
  {x=85,y=191,side=-1,a=0.09,old=0.09}}
 bumpers={{x=43,y=62,r=8,flash=0},
  {x=81,y=62,r=8,flash=0},{x=62,y=84,r=8,flash=0}}
 targets={{x=43,y=121,on=false,flash=0},
  {x=62,y=125,on=false,flash=0},{x=81,y=121,on=false,flash=0}}
 walls={
  {8,172,8,39},{8,39,14,20},{14,20,30,8},
  {30,8,96,8},{96,8,112,22},{112,22,123,40},
  {123,40,123,211},{112,51,112,211},
  {8,172,22,201},{22,201,39,211},
  {112,172,100,201},{100,201,85,211},
  {20,47,25,32},{25,32,33,25},
  {99,47,94,32},{94,32,89,25},
  {19,142,28,158},{28,158,37,172},
  {105,142,96,158},{96,158,87,172},
  {18,177,36,188},{106,177,88,188}}
 say("a journey after midnight",150)
end

function ball_at(x,y,vx,vy)
 local b={x=x,y=y,vx=vx,vy=vy,r=2,cd=0,trail={},age=0}
 add(balls,b)
 return b
end

function points(n,x,y)
 g.score=min(30000,g.score+n*g.mult)
 if x then add(floats,{x=x,y=y,t=45,s=tostr(n*g.mult).."00"}) end
end

function say(s,t)
 message=s message_time=t or 120
end

function burst(x,y,c,n)
 for i=1,n do
  if #particles<64 then
   local a=rnd(1) local v=0.3+rnd(1.4)
   add(particles,{x=x,y=y,vx=cos(a)*v,vy=sin(a)*v,t=16+rnd(18),c=c})
  end
 end
end

function launch()
 if not g.ready then return end
 ball_at(118,200,0,-4.5-g.charge*2)
 g.ready=false g.charge=0 g.save=480 g.skill=150
 sound(0) say("light r e d to raise the stakes",100)
end

-- Closest-point capsule contact. Also handles moving flipper surfaces.
function contact(b,ax,ay,bx,by,r,bounce,sx,sy)
 local dx,dy=bx-ax,by-ay
 local l=dx*dx+dy*dy
 local u=0
 if l>0 then u=mid(0,((b.x-ax)*dx+(b.y-ay)*dy)/l,1) end
 local px,py=ax+dx*u,ay+dy*u
 local nx,ny=b.x-px,b.y-py
 local rr=b.r+r
 -- Reject before squaring: long table distances overflow 16.16.
 if abs(nx)>=rr or abs(ny)>=rr then return false end
 local d=sqrt(nx*nx+ny*ny)
 if d>=rr then return false end
 if d<0.001 then nx=0 ny=-1 d=1 else nx=nx/d ny=ny/d end
 b.x=px+nx*(rr+0.03) b.y=py+ny*(rr+0.03)
 sx=(sx or 0)*u sy=(sy or 0)*u
 local speed=(b.vx-sx)*nx+(b.vy-sy)*ny
 if speed<0 then
  b.vx=b.vx-(1+bounce)*speed*nx
  b.vy=b.vy-(1+bounce)*speed*ny
 end
 return true,u,nx,ny
end

function multiball()
 if #balls<3 then
  ball_at(36,104,1.5,-2)
  if #balls<3 then ball_at(88,104,-1.5,-2.3) end
 end
 g.save=600 g.locks=0
 sound(5) shake=6 say("moonlight multiball!",180)
 burst(62,80,12,30)
end

function lane(b,i)
 if b.cd>0 then return end
 b.cd=12
 if not g.red[i] then
  g.red[i]=true points(5,38+(i-1)*24,30) sound(2)
  burst(b.x,b.y,10,8)
  if g.skill>0 then
   g.skill=0 points(25,b.x,b.y) sound(4)
   say("moonshot! 2500 skill bonus",120)
  end
 end
 if g.red[1] and g.red[2] and g.red[3] then
  g.red={false,false,false} g.mult=min(5,g.mult+1)
  g.sets=(g.sets+1)%100 points(15,62,40)
  if g.sets%2==0 then multiball()
  else say("red lanes! multiplier up",150) sound(4) end
 end
end

function defeat_hart()
 g.won=min(999,g.won+1) points(150,62,75) g.round=min(99,g.round+1)
 g.phase=1 g.hits=0 g.boss=6+min(6,g.round-1)
 g.mult=min(5,g.mult+1) g.save=600
 for t in all(targets) do t.on=false end
 sound(7) shake=8 say("dawn breaks! the wood is free",240)
 burst(62,70,10,48)
end

function damage_hart(x,y)
 if g.phase~=3 then return end
 g.boss=g.boss-1 points(10,x,y) sound(6)
 if g.boss<=0 then defeat_hart() end
end

function hit_bumper(b,p)
 if b.cd>0 then return end
 local dx,dy=b.x-p.x,b.y-p.y
 local d=max(0.1,sqrt(dx*dx+dy*dy))
 b.vx=dx/d*3.2 b.vy=dy/d*3.2-0.25 b.cd=8
 p.flash=12 shake=2 g.combo=min(99,g.combo+1) g.combo_time=120
 points(1+min(5,g.combo),p.x,p.y) sound(1)
 burst(p.x,p.y,14,10)
 if g.phase==1 then
  g.hits=g.hits+1
  if g.hits>=6 then
   g.phase=2 say("wolf defeated! shoot cottage",180) sound(4)
   points(30,62,80)
  end
 elseif g.phase==3 then damage_hart(p.x,p.y) end
end

function scoop(b,kind)
 if b.cd>0 then return end
 b.cd=45 b.vy=-2.8 b.vx=kind==1 and 1.8 or -1.8
 points(5,b.x,b.y) burst(b.x,b.y,12,12) sound(3)
 if kind==1 and g.phase==2 then
  g.phase=3 multiball() say("grandma safe! break the hart",180)
  points(50,b.x,b.y)
 elseif kind==2 and #balls>1 then
  g.jackpots=min(999,g.jackpots+1) points(50,b.x,b.y)
  say("moonlight jackpot!",120) sound(7) shake=5
 else
  g.locks=g.locks+1
  if g.locks>=3 then multiball()
  else say("moon lock "..g.locks.."/3",90) end
 end
end

function tick_ball(b)
 b.cd=max(0,b.cd-1) b.age=min(30000,b.age+1)
 add(b.trail,{x=b.x,y=b.y})
 if #b.trail>7 then deli(b.trail,1) end
 for step=1,4 do
  b.vy=min(5.8,b.vy+0.026)
  b.vx=mid(-5.8,b.vx*0.9994,5.8)
  b.vy=max(-6.5,b.vy)
  b.x=b.x+b.vx/4 b.y=b.y+b.vy/4
  -- One-way shooter gate turns the plunger shot into the upper orbit.
  if b.x>112 and b.y<44 and b.vy<0 then
   b.x=109 b.vx=-2.7 b.vy=-2.5
  end
  for w in all(walls) do contact(b,w[1],w[2],w[3],w[4],0.7,0.72) end
  for f in all(flippers) do
   local a=f.old+(f.a-f.old)*step/4
   local ex,ey=f.x+f.side*cos(a)*19,f.y-sin(a)*19
   local ox,oy=f.x+f.side*cos(f.old)*19,f.y-sin(f.old)*19
   local tx,ty=f.x+f.side*cos(f.a)*19,f.y-sin(f.a)*19
   local hit,u,nx,ny=contact(b,f.x,f.y,ex,ey,2,0.62,tx-ox,ty-oy)
   if hit and f.active and ny<0 and g.tilt==0 then
    -- A fresh stroke launches; held bats support/cradle without repeat kicks.
    if f.a-f.old < -0.002 then
     b.vy=min(b.vy,-3.6-u*2)
     b.vx=f.side*(0.6+u*2.1)
    end
   end
  end
  for p in all(bumpers) do
   if contact(b,p.x,p.y,p.x,p.y,p.r,0.9) and g.tilt==0 then hit_bumper(b,p) end
  end
  if g.tilt>0 then
   for t in all(targets) do contact(b,t.x-4,t.y,t.x+4,t.y,1,0.9) end
  else
   for i=1,3 do
    if abs(b.x-(38+(i-1)*24))<7 and abs(b.y-31)<3 then lane(b,i) end
   end
   for t in all(targets) do
    if contact(b,t.x-4,t.y,t.x+4,t.y,1,0.9) and b.cd==0 then
     t.on=true t.flash=12 b.cd=8 b.vy=-abs(b.vy)-0.5
     points(3,t.x,t.y) sound(2) burst(t.x,t.y,10,6)
     if targets[1].on and targets[2].on and targets[3].on then
      for q in all(targets) do q.on=false end
      points(20,t.x,t.y) damage_hart(t.x,t.y)
      if g.phase~=3 then g.save=max(g.save,300) say("lanterns lit! ball save",100) end
     end
    end
   end
   for i=1,2 do
    local x=i==1 and 24 or 100
    if abs(b.x-x)<5 and abs(b.y-110)<5 then scoop(b,i) end
   end
   -- Slingshots: contact on their facing edges.
   for i=1,2 do
    local x=i==1 and 30 or 94
    if contact(b,x,163,x+(i==1 and 12 or -12),180,1,1) and b.cd==0 then
     b.vx=i==1 and 2.6 or -2.6 b.vy=-2.3 b.cd=10
     points(1) sound(1) burst(b.x,b.y,9,6)
    end
   end
  end
 end
 if b.y>218 then
  del(balls,b)
  if g.save>0 and g.tilt==0 then
   ball_at(118,200,0,-6) sound(3) say("lantern save",100)
  elseif #balls==0 then
   g.wait=100 g.mult=max(1,g.mult-1) g.combo=0
   say("into the dark...",100) sound(8)
  end
 end
end

function ball_contact(a,b)
 local dx,dy=b.x-a.x,b.y-a.y
 if abs(dx)>=4 or abs(dy)>=4 then return end
 local d=sqrt(dx*dx+dy*dy)
 if d>=4 then return end
 if d<0.01 then dx=1 dy=0 d=1 else dx=dx/d dy=dy/d end
 local separation=(4-d)/2+0.01
 a.x=a.x-dx*separation a.y=a.y-dy*separation
 b.x=b.x+dx*separation b.y=b.y+dy*separation
 local speed=(a.vx-b.vx)*dx+(a.vy-b.vy)*dy
 if speed>0 then
  a.vx=a.vx-speed*dx a.vy=a.vy-speed*dy
  b.vx=b.vx+speed*dx b.vy=b.vy+speed*dy
 end
end

function tick_game(left,right,plunge,nudge)
 if g.over then return end
 g.save=max(0,g.save-1) g.heat=max(0,g.heat-0.004) g.skill=max(0,g.skill-1)
 g.tilt=max(0,g.tilt-1)
 g.combo_time=max(0,g.combo_time-1)
 if g.combo_time==0 then g.combo=0 end
 if g.wait>0 then
  g.wait=g.wait-1
  if g.wait==0 then
   g.ball=g.ball+1 g.tilt=0 g.heat=0
   if g.ball>3 then
    g.over=true sound(8)
    if g.score>best then best=g.score dset(0,best) end
   else g.ready=true say("ball "..g.ball.." - hold x to launch",150) end
  end
 end
 for i,f in ipairs(flippers) do
  f.old=f.a f.active=(i==1 and left or i==2 and right) and g.tilt==0
  local target=f.active and -0.075 or 0.09
  f.a=f.a+mid(-0.035,target-f.a,0.021)
  if f.active and f.old==0.09 then
   sound(9)
   if i==1 then g.red={g.red[2],g.red[3],g.red[1]}
   else g.red={g.red[3],g.red[1],g.red[2]} end
  end
 end
 if g.ready then
  if plunge then g.charge=min(1,g.charge+0.025)
  elseif g.charge>0 then launch() end
 end
 if nudge and #balls>0 and g.tilt==0 then
  g.heat=g.heat+1 shake=4 sound(10)
  if g.heat>2.6 then
   g.tilt=240 g.save=0 say("tilt! flippers disabled",160)
  else
   for b in all(balls) do b.vy=b.vy-1.6 b.vx=b.vx+(left and 0.8 or -0.8) end
   say(g.heat>1.6 and "danger! let the table settle" or "nudge",60)
  end
 end
 -- New multiballs enter on the next frame, never while iterating collisions.
 local active={}
 for b in all(balls) do add(active,b) end
 for b in all(active) do tick_ball(b) end
 for i=1,#balls-1 do
  for j=i+1,#balls do ball_contact(balls[i],balls[j]) end
 end
 for p in all(bumpers) do p.flash=max(0,p.flash-1) end
 for t in all(targets) do t.flash=max(0,t.flash-1) end
end
