# RED: Midnight Pinball — v1.0.0

The first standalone release of RED's native PICO-8 pinball adventure.
Journey through Lantern Wood with Red, the Wolf, Grandmother and the Briar Hart.

## Play

- **Web:** extract `red-midnight-pinball-v1.0.0-web.zip`, open `index.html`, then click Play. No PICO-8 installation required.
- **Desktop:** download the macOS, Windows, Linux or Raspberry Pi ZIP and launch the extracted application. macOS includes Apple Silicon and Intel binaries.
- **PICO-8:** drag `red-midnight.p8.png` into PICO-8 and type `run`. The editable `.p8` cartridge and an archive containing both formats are also included.
- **Preview:** `midnight-gameplay.mp4` is a 14-second showcase with original chiptune audio. Screenshots and an animated preview are in the [README](https://github.com/szabadkai/red-midnight-pinball#screenshots).

**Controls:** Left/Right flippers, hold/release X or Down to launch, Z nudge, hold Up to inspect the upper table, Esc/Enter pause. Release X after confirming Play, then press it again to charge.

## Included

- Scrolling 128×224 woodland playfield, animated cast and reactive lighting/effects.
- Wolf bumper mission, Grandmother rescue scoop and Briar Hart boss progression.
- Three-ball Moonlight Multiball, jackpots, skill shots, lane-light switching and 5× multipliers.
- Four-substep physics, moving flippers, ball collisions, slingshots, nudging, tilt and timed ball saves.
- Original three-channel soundtrack and eleven synthesized effects.
- Persistent best score, sound and motion preferences, in-game field guide and three-ball game loop.
- Editable Lua, original character source sheets/Aseprite files, asset generator, regression fixtures, capture tools and CI.

## Validation

- `npm test`: both test suites pass; 31 simulation/input checks plus cartridge-resource checks, including a 500-second simulation soak.
- `npm run test:native`: all 31 checks pass in actual PICO-8, including a 30-second fixed-point soak.
- `npm run release:package`: official cartridge, browser and four native platform exports succeed; all ZIPs pass integrity checks.
- Gameplay and menus were manually checked in the official browser player; the native showcase was captured using PICO-8 on macOS.
- Windows, Linux and Raspberry Pi exports have not been manually playtested.

The showcase contains scripted inputs and a staged Hart encounter, with live physics and scoring. The measured native showcase stayed within the 60 fps CPU budget (`stat(1)` peak 0.439 against a 0.5 budget).

`SHA256SUMS.txt` covers every attached game archive, cartridge and video. All game archives include controls, credits and rights notices. Source availability does not grant a blanket asset-reuse license.
