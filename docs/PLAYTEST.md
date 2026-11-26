# Midnight Pinball playtest

Validated on 26 November 2026 with installed PICO-8 0.2.6b, its official
HTML/JavaScript export, and stock Lua. This is an independent native cartridge;
the platformer campaign and its public release route are not replaced.

## Evidence

- [14-second native gameplay recording with sound](media/midnight-gameplay.mp4)
- [Animated GIF](media/midnight-gameplay.gif)
- [Title screen](media/midnight-90.png)
- [Wolf bumpers and orbit](media/midnight-220.png)
- [Rescue scoop lit](media/midnight-440.png)
- [Hart / multiball fixture](media/midnight-570.png)

The clip is captured by PICO-8's own GIF and audio recorder. It starts at the
title, launches into live physics, and at frame 510 switches to an explicit
three-ball Hart fixture. Flipper inputs are scripted for reproducibility;
collisions, score changes, particles and camera tracking run normally. It is
a feature showcase, not a claim of an unassisted complete playthrough.

Run `node tools/capture-pinball.mjs` from the root to reproduce the capture.
The capture code is injected into an ignored `dist/showcase.p8`, never into
the playable source or release cartridge. It does not write player saves.

## Manual reproduction

1. Run `npm start`, or open the official exported browser player.
2. Press **Z** at the title. Switch guide pages with **Left/Right**; check every
   line fits. **Z** returns to title; **X** starts a game.
3. Hold **X** for roughly one second and release. The ball travels up the right
   shooter lane into the orbit. Watch ball trails, metal highlights and the
   eight-second lantern-save countdown. A weak plunger shot can fall back down.
4. Use **Left/Right** independently. The flippers also rotate lit RED lanes.
   Hit bumpers to build the combo and defeat the Wolf at six hits. Complete RED
   for a multiplier increase; a quick launch lane awards the skill-shot bonus.
5. After the Wolf, the left cottage flashes cyan. Shoot it to rescue Grandmother
   and start multiball. The right well now pays jackpots. Hit red bumpers or
   complete lantern banks to defeat the Hart and begin a harder journey.
6. Use **Z** three times quickly: TILT disables flippers and cancels ball save.
   Let the heat settle before nudging again. Allow three unsaved turns to drain
   and check the result panel, retry, and persistent best score.
7. Press **Enter/Esc**, navigate to **Field guide**, and confirm. Switch guide
   pages, then return with **Z**. Score, ball number and save time are preserved
   while reading. Test sound and reduced-motion options in the same pause menu.

Manual checks exercised both flippers, launch, nudge, scoring, Wolf defeat,
Grandmother rescue, multiball, Hart defeat, both guide pages, pause navigation,
and guide return to the same game in the official browser runtime. The final
native recording separately exercises the actual fixed-point engine.

## Automated validation

- `npm test`: **31 simulation checks pass**, plus cartridge/source
  and resource-layout checks. Includes a deterministic 30,000-frame / 500-second
  soak with changing flipper inputs and repeated complete games.
- `npm run test:native`: **the same 31 checks pass in actual PICO-8**,
  including a 1,800-frame / 30-second fixed-point soak. Persistence writes are
  stubbed in this fixture; the player's high score is untouched.
- `npm run build`: official `.p8.png` and HTML/JS exports succeed.

Regression coverage includes charge/release, shooter exit, lane switching,
one-shot skill awards, separating contacts, distant fixed-point contacts,
moving and held flippers, ball-to-ball momentum exchange, saved/unsaved drains,
turn counting, game over, capped multiball, scoring cooldowns, all mission
transitions, multiplier awards, score saturation, tilt and simulation bounds.

The final native showcase measured `stat(1)` at **0.3023 mean / 0.439 peak**.
PICO-8's 60 fps budget is 0.5 on that scale. This is a measured showcase budget,
not an exhaustive guarantee across every future table state or host device.
The standard cartridge exports within the 8,192-token and compressed-code
limits; no token-limit bypass, external runtime or multicart is used.

For review before merge, request a second developer per the repository guide.
The standalone repository and v1.0.0 release were subsequently packaged from this validated cartridge; gameplay source is unchanged.
