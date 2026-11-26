import {existsSync, mkdirSync, readFileSync, writeFileSync} from 'node:fs';
import {spawn, spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import path from 'node:path';

const root = fileURLToPath(new URL('../', import.meta.url));
const project = root;
export const cart = path.join(project, 'red-midnight.p8');
export function assemble() {
  const code = ['simulation', 'renderer', 'main'].map(name =>
    readFileSync(path.join(project, 'src', `${name}.lua`), 'utf8')).join('\n');
  let data = `pico-8 cartridge // http://www.pico-8.com\nversion 42\n__lua__\n${code}`;
  for (const section of ['gfx', 'label', 'sfx', 'music']) {
    data += `\n__${section}__\n${readFileSync(path.join(project, 'assets', `${section}.txt`), 'utf8')}`;
  }
  writeFileSync(cart, data);
  return cart;
}

export function pico8() {
  const candidates = [process.env.PICO8_BIN,
    '/Applications/PICO-8.app/Contents/MacOS/pico8',
    'C:/Program Files (x86)/PICO-8/pico8.exe', 'C:/Program Files/PICO-8/pico8.exe'].filter(Boolean);
  const found = candidates.find(existsSync);
  if (found) return found;
  const which = spawnSync(process.platform === 'win32' ? 'where' : 'which', ['pico8'], {encoding:'utf8'});
  if (which.status === 0) return which.stdout.trim().split(/\r?\n/)[0];
  throw new Error('Install PICO-8 or set PICO8_BIN to its executable. The .p8 cartridge is ready to open.');
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const mode = process.argv[2] || 'play';
  assemble();
  if (mode === 'assemble') console.log(cart);
  else if (mode === 'build') {
    const out = path.join(project, 'dist');
    mkdirSync(out, {recursive:true});
    for (const extension of ['p8.png', 'html']) {
      const result = spawnSync(pico8(), ['red-midnight.p8', '-export', `dist/red-midnight.${extension}`],
        {cwd:project, encoding:'utf8', timeout:60000});
      process.stdout.write(result.stdout || '');
      process.stderr.write(result.stderr || '');
      if (result.status !== 0 || /error|exceed|failed/i.test(result.stdout + result.stderr)
          || !existsSync(path.join(out, `red-midnight.${extension}`))) process.exit(1);
    }
    console.log(`Built native cartridge and official PICO-8 web player in ${out}`);
  } else {
    const args = mode === 'edit' ? ['red-midnight.p8'] : ['-run', 'red-midnight.p8'];
    const child = spawn(pico8(), [...args, ...process.argv.slice(3)], {cwd:project, stdio:'inherit'});
    child.on('error', error => {console.error(error.message); process.exitCode=1;});
    child.on('exit', code => {process.exitCode=code ?? 1;});
  }
}
