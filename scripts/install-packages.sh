#!/bin/sh

set -e

wally install
rojo sourcemap default.project.json -o sourcemap.json

wally-package-types -s sourcemap.json Packages/

if [ ! -d "ServerPackages" ]; then
  wally-package-types -s sourcemap.json ServerPackages/
fi

