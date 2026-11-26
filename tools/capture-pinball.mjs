// Reproducible attract/play/boss showcase in the real PICO-8 runtime.
// Fixture transitions are deliberate; the balls and collisions remain live.
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {spawn} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {assemble,pico8} from './pinball.mjs';
const root=fileURLToPath(new URL('../',import.meta.url));
const out=path.join(root,'docs/media');
const dir=path.join(root,'dist');
mkdirSync(out,{recursive:true}); mkdirSync(dir,{recursive:true});
const source=readFileSync(assemble(),'utf8');
const replay=`
local original_init=_init
local original_update=_update60
local original_draw=_draw
local replay_frame=0
local peak=0
local total_cpu=0
local measured=0
local buttons={}
btn=function(n) return buttons[n] or false end
btnp=function(n) return false end
cartdata=function() end
dget=function() return 0 end
dset=function() end
function _init()
 original_init()
 extcmd("set_filename","midnight-gameplay")
 extcmd("rec")
 extcmd("audio_rec")
end
function _update60()
 replay_frame=replay_frame+1
 buttons={}
 if replay_frame==120 then start_game() g.charge=1 launch() end
 if replay_frame>120 then
  for b in all(balls) do
   if b.y>174 and b.y<197 and b.vy>0 then
    buttons[b.x<62 and 0 or 1]=true
   end
  end
  if g.ready then buttons[5]=replay_frame%90<55 end
 end
 if replay_frame==510 then
  start_game() g.ready=false g.phase=3 g.boss=12
  ball_at(62,36,1.4,0.6) multiball()
  say("grandma safe! break the hart",180)
 end
 original_update()
end
function _draw()
 original_draw()
 if replay_frame>120 then
  peak=max(peak,stat(1)) total_cpu=total_cpu+stat(1) measured=measured+1
 end
 if replay_frame==90 or replay_frame==220 or replay_frame==440 or replay_frame==570 then
  extcmd("set_filename","midnight-"..replay_frame)
  extcmd("screen",4)
 end
 if replay_frame==960 then
  extcmd("set_filename","midnight-gameplay")
  extcmd("video",4)
  extcmd("audio_end")
  printh("PINBALL CPU peak="..peak.." mean="..total_cpu/measured)
  extcmd("shutdown")
 end
end
`;
writeFileSync(path.join(dir,'showcase.p8'),source.replace('__gfx__',replay+'__gfx__'));
const child=spawn(pico8(),['-run','showcase.p8','-width','640','-height','640','-windowed','1',
  '-desktop',out,'-gif_len','20','-gif_scale','4'],{cwd:dir,stdio:'inherit'});
child.on('exit',code=>{process.exitCode=code??1;});
