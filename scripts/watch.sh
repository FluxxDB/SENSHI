#!/bin/sh

set -e

os=$(uname)

if [[ "$os" == "Linux" ]]; then
  ./scripts/watchers/linux.sh
#elif [[ "$os" == "Darwin" ]]; then
  #./scripts/watchers/mac.sh
elif [[ "$os" == "CYGWIN"* || "$os" == "MINGW"* || "$os" == "MSYS"* ]]; then
  ./scripts/watchers/windows.ps1  
fi
