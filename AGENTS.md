# Repository guidelines

This is the standalone native PICO-8 spin-off of RED. Run commands from this
repository root. Gameplay belongs in `src/simulation.lua`; drawing belongs in
`src/renderer.lua`; input, persistence and menus belong in `src/main.lua`.

After source changes, run `npm run assemble` and commit the resulting cartridge.
Run `npm test`; when PICO-8 is available also run `npm run test:native` and
`npm run build`. Preserve source artwork, music generators and rights notices.
Use `npm run capture` for visual changes and update the playtest notes.

Use concise imperative commits. Include behavior, tests, controls and screenshots
in PR descriptions when relevant. Request a second developer's review before
merging gameplay changes.
