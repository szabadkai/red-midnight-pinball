"""Package already exported files; retain native ZIP permissions and notices."""
import hashlib
import json
from pathlib import Path
import shutil
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VERSION = json.loads((ROOT / 'package.json').read_text())['version']
DIST = ROOT / 'dist'
OUT = DIST / ('release-v' + VERSION)
OUT.mkdir(exist_ok=True)
PREFIX = f'red-midnight-pinball-v{VERSION}'
NOTICES = {
    'README.txt': ROOT / 'docs/PLAYER_GUIDE.txt',
    'CREDITS.md': ROOT / 'CREDITS.md',
    'ASSET_RIGHTS.md': ROOT / 'ASSET_RIGHTS.md',
    'docs/ORIGINAL_ASSET_RIGHTS.md': ROOT / 'docs/ORIGINAL_ASSET_RIGHTS.md',
    'docs/PILLOW_LICENSE.txt': ROOT / 'docs/PILLOW_LICENSE.txt',
}

def archive(name, files):
    with zipfile.ZipFile(OUT / name, 'w', zipfile.ZIP_DEFLATED) as z:
        for target, source in {**files, **NOTICES}.items():
            z.write(source, target)

archive(PREFIX + '-web.zip', {'index.html': DIST / 'red-midnight.html',
                            'red-midnight.js': DIST / 'red-midnight.js'})
archive(PREFIX + '-cartridges.zip', {'red-midnight.p8': ROOT / 'red-midnight.p8',
                                   'red-midnight.p8.png': DIST / 'red-midnight.p8.png'})
for platform in ['windows', 'linux', 'osx', 'raspi']:
    original = DIST / 'red-midnight.bin' / f'red-midnight_{platform}.zip'
    destination = OUT / f'{PREFIX}-{platform}.zip'
    shutil.copy2(original, destination)
    # Append notices without changing the original entries or executable bits.
    with zipfile.ZipFile(destination, 'a', zipfile.ZIP_DEFLATED) as z:
        for target, source in NOTICES.items():
            z.write(source, target)

for source in [ROOT / 'red-midnight.p8', DIST / 'red-midnight.p8.png',
               ROOT / 'docs/media/midnight-gameplay.mp4']:
    shutil.copy2(source, OUT / source.name)
files = sorted(p for p in OUT.iterdir() if p.name != 'SHA256SUMS.txt')
for file in files:
    if file.suffix == '.zip':
        with zipfile.ZipFile(file) as z:
            assert z.testzip() is None, file.name
checksums = ''.join(hashlib.sha256(p.read_bytes()).hexdigest() + '  ' + p.name + '\n' for p in files)
(OUT / 'SHA256SUMS.txt').write_text(checksums)
print(f'Packaged {len(files)} assets and verified ZIP integrity: {OUT}')
