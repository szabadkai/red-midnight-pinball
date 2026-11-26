# Credits and provenance

## Characters

The cast comes from [RED — The Gambler's Clearing](https://github.com/szabadkai/red-gamblers-clearing).
Original PNG sheets, JSON frame metadata and Aseprite files are retained under
`sources/lrrh_sprites/`:

| Character | Source basename |
| --- | --- |
| Red | `little_red_riding_hood_small` |
| Grandmother | `grandmother_small` |
| Wolf | `big_bad_wolf` |
| Briar Hart | `bosses/briar_hart` |

The converter uses four idle frames per character, two for the Hart, consistent
frame bounds, nearest-neighbor resizing and the PICO-8 palette. The output is
`assets/cast.png`, with native cartridge data in `assets/gfx.txt`.
No purchased character packs were added to this game. Existing rights remain
unchanged; see [ASSET_RIGHTS.md](ASSET_RIGHTS.md).

## Original table and sound

The table, forest silhouettes, title treatment, particles and cabinet details
are code-drawn for Midnight Pinball. **Lanterns After Midnight** is an original
eight-bar chiptune arrangement with eleven synthesized gameplay effects.
The editable conversion and score are in `tools/generate-pinball-assets.py`.
The label uses Pillow's bundled default font.

## Tools

- **PICO-8**, its cartridge format and exported player: Lexaloffle Games.
- **Aseprite**: original character source format.
- **Pillow**: offline palette conversion and label generation; its bundled
  font is Aileron Regular. Pillow's license notices are retained in `docs/PILLOW_LICENSE.txt`.
- **FFmpeg**: MP4 encoding of PICO-8's GIF/audio recording.

The author's PICO-8 installation is required for exports; it is not distributed
in the source tree. Generated player files retain the official exporter output.
