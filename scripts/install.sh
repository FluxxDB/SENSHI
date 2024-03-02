#!/bin/sh

set -e

aftman install && \
  sh scripts/install-packages.sh
