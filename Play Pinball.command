#!/bin/zsh
cd "$(dirname "$0")" || exit 1
node tools/pinball.mjs play
