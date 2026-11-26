"""Reproducible PICO-8 palette adaptation and original four-voice score.

Run with Python + Pillow. Does not alter source artwork.
"""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets'
OUT.mkdir(parents=True, exist_ok=True)
PALETTE = ['000000', '1d2b53', '7e2553', '008751', 'ab5236', '5f574f',
           'c2c3c7', 'fff1e8', 'ff004d', 'ffa300', 'ffec27', '00e436',
           '29adff', '83769c', 'ff77a8', 'ffccaa']
RGB = [tuple(bytes.fromhex(c)) for c in PALETTE]
sheet = Image.new('P', (128, 128), 0)
sheet.putpalette([c for rgb in RGB for c in rgb] + [0] * (768 - 48))

def convert(rgb):
    r, g, b, a = rgb
    if a < 128:
        return 0
    # Red's scarlet hood must remain scarlet at fantasy-console resolution.
    if r > g * 1.8 and r > b * 1.15 and r > 90:
        return 8 if r > 135 else 2
    return min(range(1, 16), key=lambda i: sum(
        (v - RGB[i][j]) ** 2 * (2 if j == 1 else 1)
        for j, v in enumerate((r, g, b))))

characters = [('little_red_riding_hood_small', 0, 24, 4),
              ('grandmother_small', 24, 24, 4),
              ('big_bad_wolf', 48, 24, 4),
              ('bosses/briar_hart', 80, 32, 2)]
for name, row, size, count in characters:
    base = ROOT / 'sources/lrrh_sprites' / (name + '_sheet')
    source = Image.open(str(base) + '.png').convert('RGBA')
    frames = json.loads(Path(str(base) + '.json').read_text())['frames'][:count]
    crops = []
    for frame in frames:
        f = frame['frame']
        crops.append(source.crop((f['x'], f['y'], f['x'] + f['w'], f['y'] + f['h'])))
    boxes = [im.getbbox() for im in crops]
    bounds = (min(b[0] for b in boxes), min(b[1] for b in boxes),
              max(b[2] for b in boxes), max(b[3] for b in boxes))
    for i, im in enumerate(crops):
        im = im.crop(bounds)
        ratio = min(1, (size - 2) / im.width, (size - 2) / im.height)
        if ratio < 1:
            im = im.resize((round(im.width * ratio), round(im.height * ratio)), Image.Resampling.NEAREST)
        ox = i * size + (size - im.width) // 2
        oy = row + size - im.height
        for y in range(im.height):
            for x in range(im.width):
                sheet.putpixel((ox + x, oy + y), convert(im.getpixel((x, y))))

sheet.save(OUT / 'cast.png', transparency=0)
gfx = '\n'.join(''.join(f'{sheet.getpixel((x,y)):x}' for x in range(128)) for y in range(128))
(OUT / 'gfx.txt').write_text(gfx + '\n')

label = Image.new('P', (128, 128), 0)
label.putpalette(sheet.getpalette())
draw = ImageDraw.Draw(label)
draw.rectangle((4, 4, 123, 123), outline=9)
for i in range(35):
    draw.point(((i*37) % 120 + 4, (i*23) % 110 + 8), fill=5)
draw.ellipse((70, 17, 107, 54), fill=13)
draw.ellipse((77, 13, 111, 47), fill=1)
draw.text((17, 16), 'RED', font=ImageFont.load_default(size=28), fill=8, stroke_width=1, stroke_fill=2)
font = ImageFont.load_default(size=10)
draw.text((13, 54), 'MIDNIGHT PINBALL', font=font, fill=15)
label.paste(sheet.crop((0, 0, 24, 24)).resize((36, 36), Image.Resampling.NEAREST), (23, 72))
label.paste(sheet.crop((0, 48, 24, 72)).resize((36, 36), Image.Resampling.NEAREST), (72, 72))
draw.ellipse((60, 85, 65, 90), fill=7)
draw.text((17, 111), 'LANTERN WOOD', font=font, fill=10)
label.save(OUT / 'label.png')
(OUT / 'label.txt').write_text('\n'.join(''.join(f'{label.getpixel((x,y)):x}'
    for x in range(128)) for y in range(128)) + '\n')

def sfx(notes, speed=8, wave=0, volume=4, loop=False):
    values = []
    for note in notes[:32]:
        if isinstance(note, tuple):
            pitch, w, v, fx = note
        else:
            pitch, w, v, fx = (note or 0), wave, (volume if note is not None else 0), 0
        values.append(f'{pitch:02x}{w:x}{v:x}{fx:x}')
    values += ['00000'] * (32 - len(values))
    return f'00{speed:02x}00{32 if loop else 0:02x}' + ''.join(values)

sounds = [sfx([], 8) for _ in range(64)]
effects = [
    ([(18+i*2, 0, 5, 1) for i in range(12)], 2),
    ([(43, 0, 6, 0), (50, 0, 4, 0), (55, 0, 2, 3)], 3),
    ([38, 45, 50, 57], 3),
    ([26, 33, 38, 45, 50, 57], 4),
    ([38, 42, 45, 50, 54, 57, 62], 5),
    ([26, 38, 33, 45, 38, 50, 45, 57, 50, 62], 5),
    ([(20, 6, 5, 0), (15, 3, 5, 1), (8, 3, 3, 3)], 4),
    ([38, 42, 45, 50, 45, 50, 54, 57, 62], 6),
    ([(30-i*2, 2, max(1, 5-i//3), 3) for i in range(12)], 5),
    ([(18, 6, 3, 0), (12, 6, 1, 3)], 1),
    ([(10, 6, 4, 0), (6, 6, 2, 3)], 3),
]
for i, (notes, speed) in enumerate(effects):
    sounds[i] = sfx(notes, speed, 0, 5)

# Lanterns After Midnight: eight original bars, D minor / Bb / F / C.
# Channels 0-2 are the score; channel 3 is reserved for responsive game SFX.
melodies = [
    [50,None,57,None,53,52,50,None,45,None,50,52,53,None,57,None],
    [58,None,57,53,50,None,53,None,45,50,53,None,52,None,50,None],
    [53,None,60,None,57,55,53,None,48,None,53,55,57,None,60,None],
    [55,None,52,None,48,50,52,None,43,None,48,52,55,None,52,None],
    [62,None,57,53,50,None,57,None,62,60,57,None,53,None,50,None],
    [58,None,62,None,65,62,58,None,53,None,57,58,62,None,58,None],
    [60,None,57,53,48,None,53,None,57,60,65,None,60,None,57,None],
    [55,None,52,48,43,None,48,None,52,55,57,55,52,None,49,None],
]
roots = [26, 22, 29, 24] * 2
chords = [[38,41,45,50], [34,38,41,46], [41,45,48,53], [36,40,43,48]] * 2
music = []
for i, melody in enumerate(melodies):
    lead, bass, arp = 16+i*3, 17+i*3, 18+i*3
    expanded = []
    for n in melody:
        expanded.extend([(n or 0, 2, 3 if n is not None else 0, 0), (n or 0, 2, 1 if n is not None else 0, 3)])
    sounds[lead] = sfx(expanded, 9)
    sounds[bass] = sfx([roots[i] if j%8==0 else (roots[i]+12 if j%8==4 else None) for j in range(32)], 9, 0, 3)
    sounds[arp] = sfx([(chords[i][j%4], 0, 2 if j%2==0 else 1, 3) for j in range(32)], 9)
    music.append(f'{1 if i==0 else 2 if i==7 else 0:02x} {lead:02x}{bass:02x}{arp:02x}44')
(OUT / 'sfx.txt').write_text('\n'.join(sounds) + '\n')
(OUT / 'music.txt').write_text('\n'.join(music) + '\n')
print('Adapted 14 character frames; composed 8 bars and 11 effects.')
