#!/bin/sh
# Lays out the av archive in stage/: the start script at the top, the
# standalone program from asciiverse/build.sh in bin/ and lib/.
set -eu
cd "$(dirname "$0")/.."
rm -rf stage && mkdir stage
cp asciiverse/terminal-phase stage/terminal-phase
cp -R build/dist/bin build/dist/lib stage/
cp LICENSE.txt README.org PATCHES.md stage/
