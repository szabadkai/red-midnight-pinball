import {readFileSync, writeFileSync, mkdirSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {assemble,pico8} from './pinball.mjs';
const root=fileURLToPath(new URL('../',import.meta.url));
const dir=path.join(root,'dist');
mkdirSync(dir,{recursive:true});
const cart=readFileSync(assemble(),'utf8');
const tests=readFileSync(path.join(root,'tests/pinball-fixtures.lua'),'utf8');
// Tests do not touch a player's cartridge data.
const code=tests+`\nfunction _init()
 best=0 muted=true soak_frames=1800 dset=function() end
 local n=pinball_checks()
 printh("PINBALL CHECKS "..n)
 extcmd("shutdown")
end\n`;
writeFileSync(path.join(dir,'checks.p8'),cart.replace('__gfx__',code+'__gfx__'));
const result=spawnSync(pico8(),['-x','checks.p8'],{cwd:dir,encoding:'utf8',timeout:60000});
process.stdout.write(result.stdout||'');
process.stderr.write(result.stderr||'');
if (result.error) console.error(result.error.message);
if (!/PINBALL CHECKS 31/.test(result.stdout)||/runtime error|syntax error/.test(result.stdout)) process.exit(1);
