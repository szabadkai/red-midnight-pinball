-- Runs unchanged in native PICO-8 (fixed point) and stock Lua via the shim.
function pinball_checks()
 local checks=0
 local function check(ok,name)
  assert(ok,name) checks=checks+1
 end
 new_game() best=0
 check(g.ready and #balls==0 and g.ball==1,"new game")
 for i=1,41 do tick_game(false,false,true,false) end
 check(g.charge==1 and #balls==0,"charge without premature launch")
 tick_game(false,false,false,false)
 check(#balls==1 and not g.ready and balls[1].vy<0,"release launches")
 local reached=false
 for i=1,100 do
  tick_game(false,false,false,false)
  if balls[1] and balls[1].x<110 and balls[1].y<65 then reached=true end
 end
 check(reached,"full plunger reaches upper orbit")
 new_game() g.red={true,false,false}
 tick_game(true,false,false,false)
 check(g.red[3] and not g.red[1],"left flipper rotates lane lights")
 new_game() g.red={true,false,false}
 tick_game(false,true,false,false)
 check(g.red[2] and not g.red[1],"right flipper rotates lane lights")
 new_game() g.charge=1 launch()
 local shot=balls[1] shot.cd=0 lane(shot,2)
 check(g.score==30 and g.skill==0,"launch skill shot pays once")

 new_game()
 local b=ball_at(50,49,0,2)
 check(contact(b,40,52,60,52,2,0.8) and b.vy<0,"wall reflects incoming ball")
 local c=ball_at(50,49,0,-2)
 contact(c,40,52,60,52,2,0.8)
 check(c.vy==-2,"separating contacts do not add energy")
 check(not contact(c,50,200,50,210,2,1),"distant contact avoids fixed-point overflow")
 local d=ball_at(60,90,2,0) local e=ball_at(63,90,-1,0)
 ball_contact(d,e)
 check(d.vx==-1 and e.vx==2 and e.x-d.x>=4,"multiball exchanges momentum")

 new_game() g.ready=false
 b=ball_at(51,193,0,1)
 tick_game(true,false,false,false)
 check(b.vy<-3,"fresh flipper launches")
 local energy=abs(b.vy)
 for i=1,40 do tick_game(true,false,false,false) end
 check(flippers[1].a<0 and flippers[1].old==flippers[1].a,"held flipper stops rotating")

 new_game() g.ready=false g.save=30
 b=ball_at(62,221,0,2) tick_ball(b)
 check(#balls==1 and balls[1]~=b and g.ball==1 and g.wait==0,"save replaces drain")
 g.save=0 b=balls[1] b.x=62 b.y=221 b.vy=2 tick_ball(b)
 check(#balls==0 and g.wait==100,"last ball starts drain delay")
 for i=1,100 do tick_game(false,false,false,false) end
 check(g.ball==2 and g.ready,"only last drain spends a ball")
 g.ball=3 g.ready=false g.score=123 g.wait=1
 tick_game(false,false,false,false)
 check(g.over and best==123,"game over persists best")

 new_game() g.ready=false
 b=ball_at(62,100,0,0)
 multiball() multiball()
 check(#balls==3,"multiball never exceeds three")
 g.save=0 b.x=62 b.y=221 tick_ball(b)
 check(#balls==2 and g.wait==0 and g.ball==1,"multiball drain preserves turn")

 new_game() b=ball_at(62,100,0,0)
 for i=1,6 do b.cd=0 hit_bumper(b,bumpers[1]) end
 check(g.phase==2,"wolf lights rescue scoop")
 local score=g.score
 hit_bumper(b,bumpers[1])
 check(g.score==score,"contact cooldown prevents farming")
 b.cd=0 scoop(b,1)
 check(g.phase==3 and #balls==3,"cottage rescues grandma and starts multiball")
 local hp=g.boss
 for i=1,hp do damage_hart(62,70) end
 check(g.won==1 and g.phase==1 and g.round==2,"hart victory starts next journey")

 new_game() b=ball_at(62,100,0,0)
 for set=1,2 do for i=1,3 do b.cd=0 lane(b,i) end end
 check(g.mult==3 and #balls==3,"two RED sets award multiball and multiplier")
 g.score=29999 g.mult=5 points(150)
 check(g.score==30000,"score saturates before fixed-point overflow")

 new_game() g.ready=false ball_at(62,100,0,0)
 for i=1,3 do tick_game(false,false,false,true) end
 check(g.tilt>0 and g.save==0,"three quick nudges tilt")
 tick_game(true,true,false,false)
 check(not flippers[1].active and not flippers[2].active,"tilt disables both bats")

 -- 500-second deterministic soak; native fixed-point run uses 30 seconds.
 new_game() local escaped=false local journeys=0
 for frame=1,(soak_frames or 30000) do
  if g.over then journeys=journeys+1 new_game() end
  tick_game(frame%37<12,frame%43<14,g.ready and frame%60<35,false)
  for q in all(balls) do
   if q.x<0 or q.x>128 or q.y<0 or q.x~=q.x or q.y~=q.y then escaped=true end
  end
 end
 check(not escaped,"soak: no escaped or non-finite balls")
 check((soak_frames and g.ball<=4) or journeys>0,"soak: bounded game lifecycle")
 -- Confirming Play must not carry X into a weak, accidental launch.
 tick=0 motion=true shake=0 menu_delay=0 muted=true
 local holding=true
 btn=function(n) return n==5 and holding end
 btnp=function() return false end
 start_game() _update60()
 check(g.ready and g.charge==0,"play button does not charge plunger")
 holding=false _update60()
 holding=true _update60()
 holding=false _update60()
 check(not g.ready and #balls==1,"new press after play arms plunger")
 return checks
end
