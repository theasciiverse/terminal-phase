#!/bin/sh
# Builds a standalone Terminal Phase into build/dist/: bin/terminal-phase
# plus lib/plt (the Racket runtime, the game's levels and credits,
# and two small native libraries). Players need no Racket.
#
# Needs Racket 8 (CS) and its package catalog; installs the game's
# libraries (lux, goblins, pk, raart, ansi) in the user scope, or wherever
# PLTADDONDIR points. raco pkg install builds the two native helpers,
# ansi's libtty_raw and unix-signals' libracket_unix_signals, with the C
# compiler.
#   sh asciiverse/build.sh && sh asciiverse/stage.sh
set -eu
cd "$(dirname "$0")/.."
raco pkg install --auto --batch --skip-installed --no-docs \
  lux goblins pk raart ansi
raco make -v terminal-phase.rkt
rm -rf build && mkdir -p build/collects
raco exe -o build/terminal-phase terminal-phase.rkt
# ansi and unix-signals find their native libraries through
# (collection-path ...), so the standalone tree needs those collection
# folders with the compiled/native files in them.
for c in ansi unix-signals; do
  src=$(racket -e "(display (collection-path \"$c\"))")
  mkdir -p "build/collects/$c/private/compiled"
  cp -R "$src/private/compiled/native" "build/collects/$c/private/compiled/"
done
raco distribute ++collects-copy build/collects build/dist build/terminal-phase
