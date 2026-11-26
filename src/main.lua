function sound(n)
 if not muted then sfx(n,3) end
end

function _init()
 cartdata("red_midnight_pinball_v1")
 best=dget(0) muted=dget(1)==1 motion=dget(2)~=1
 tick=0 cam=100 shake=0 message_time=0 page=1 state="title" menu_delay=0
 new_game()
 cache_table()
 if not muted then music(0,800,7) end
 menuitem(1,"sound on/off",function()
  muted=not muted dset(1,muted and 1 or 0)
  if muted then music(-1) sfx(-1,3) else music(0,400,7) end
 end)
 menuitem(2,"motion on/off",function() motion=not motion dset(2,motion and 0 or 1) end)
 menuitem(3,"field guide",function() previous=state state="guide" menu_delay=12 end)
 menuitem(4,"title screen",function() state="title" menu_delay=12 end)
end

function start_game()
 new_game() state="play" cam=100 launch_armed=false
end

function _update60()
 tick=(tick+1)%7200
 if menu_delay>0 then menu_delay=menu_delay-1 return end
 if state=="title" then
  if btnp(5) then start_game()
  elseif btnp(4) then state="guide" previous="title" end
 elseif state=="guide" then
  if btnp(0) or btnp(1) then page=3-page sound(2) end
  if btnp(4) then state=previous or "title"
  elseif btnp(5) then
   if previous=="play" then state="play" else start_game() end
  end
 elseif g.over then
  if btnp(5) then start_game() elseif btnp(4) then state="title" end
 else
  local plunge=btn(5) or btn(3)
  if not launch_armed then
   if not plunge then launch_armed=true end
   plunge=false
  end
  tick_game(btn(0),btn(1),plunge,btnp(4))
  local target=100
  if #balls>0 then
   local lowest=0
   for b in all(balls) do
    if b.x<112 then lowest=max(lowest,b.y+b.vy*5) end
   end
   target=mid(0,lowest-63,100)
  end
  if btn(2) then target=0 end
  cam=cam+(target-cam)*(motion and 0.16 or 1)
 end
 if state=="play" then
  message_time=max(0,message_time-1) shake=max(0,shake-0.3)
  for p in all(particles) do
   p.x=p.x+p.vx p.y=p.y+p.vy p.vy=p.vy+0.035 p.t=p.t-1
   if p.t<=0 then del(particles,p) end
  end
  for f in all(floats) do
   f.y=f.y-0.2 f.t=f.t-1
   if f.t<=0 then del(floats,f) end
  end
 end
end

function _draw()
 camera() clip()
 if state=="title" then title_screen()
 elseif state=="guide" then guide_screen()
 else
  cls(0) clip(0,14,128,105)
  local jitter=motion and shake>0 and sin(tick*0.37)*shake/2 or 0
  view_y=mid(0,flr(cam+jitter),104)
  camera(0,view_y) draw_table() hud()
  if g.over then results_screen() end
 end
end
