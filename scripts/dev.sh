#!/bin/sh

set -e

if [ ! -d "Packages" ]; then
    sh scripts/install-packages.sh
fi

lune run scripts/lune/generateComponents.luau

rojo serve build.project.json \
    & rojo sourcemap default.project.json -o sourcemap.json --watch \
    & ROBLOX_DEV=true darklua process --config .darklua.json --watch src/ out/ \
    & sh scripts/watch.sh

