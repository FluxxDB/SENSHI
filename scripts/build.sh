#!/bin/sh

set -e

# If Packages aren't installed, install them.
if [ ! -d "Packages" ]; then
    sh scripts/install-packages.sh
fi

lune run scripts/lune/generateComponents.luau
rojo sourcemap default.project.json -o sourcemap.json
ROBLOX_DEV=false darklua process --config .darklua.json src/ out/
rojo build build.project.json -o senshi.rbxl
