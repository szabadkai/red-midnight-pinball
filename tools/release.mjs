import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {pico8} from './pinball.mjs';
const cwd=fileURLToPath(new URL('../',import.meta.url));
for (const [command,args] of [
  [process.execPath,['tools/pinball.mjs','build']],
  [pico8(),['red-midnight.p8','-export','dist/red-midnight.bin']],
  ['python3',['tools/package-release.py']]
]) {
  const result=spawnSync(command,args,{cwd,encoding:'utf8',timeout:120000});
  process.stdout.write(result.stdout||'');
  process.stderr.write(result.stderr||'');
  if (result.status!==0 || /error|failed/i.test(result.stdout+result.stderr)) process.exit(1);
}
