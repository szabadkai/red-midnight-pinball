import {test} from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {readFileSync, existsSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
const root=fileURLToPath(new URL('../',import.meta.url));

test('native pinball physics, missions, drains and soak regression', t => {
  const available=spawnSync('lua',['-v'],{encoding:'utf8'});
  if (available.error?.code==='ENOENT') return t.skip('Install Lua or run the native PICO-8 fixtures.');
  const run=spawnSync('lua',['tests/pinball-shim.lua'],{cwd:root,encoding:'utf8',timeout:30000});
  assert.equal(run.status,0,run.stdout+run.stderr);
  assert.match(run.stdout,/PINBALL CHECKS 31/);
});

test('cartridge packs the current sources and complete PICO-8 resources', () => {
  const cart=readFileSync(new URL('../red-midnight.p8',import.meta.url),'utf8');
  for (const file of ['simulation','renderer','main']) {
    const source=readFileSync(new URL(`../src/${file}.lua`,import.meta.url),'utf8');
    assert.ok(cart.includes(source),`assemble cartridge after editing ${file}`);
  }
  for (const [name,length] of [['gfx',128],['label',128],['sfx',64],['music',8]]) {
    const content=cart.split(`__${name}__\n`)[1].split(/\n__/)[0].trim().split('\n');
    assert.equal(content.length,length,name);
    if (name==='gfx' || name==='label') assert.ok(content.every(line=>/^[0-9a-f]{128}$/.test(line)));
    if (name==='sfx') assert.ok(content.every(line=>/^[0-9a-f]{168}$/.test(line)));
  }
  assert.ok(existsSync(new URL('../assets/cast.png',import.meta.url)));
});
