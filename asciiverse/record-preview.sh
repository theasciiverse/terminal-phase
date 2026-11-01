#!/bin/sh
# Records the 100x30 catalog preview, asciiverse/terminal-phase.cast
# (hub/RECORDING.md): the title menu, then about 40 s of level 1 flown by
# asciiverse/drive.py (fire, chase enemy rows, steer off rows where
# something is coming), back to the menu and quit. asciinema records a
# tmux pane (own socket, no status line, no user config) that drive.py
# reads and plays in. Needs asciinema 3 and tmux.
#   asciiverse/record-preview.sh stage/bin/terminal-phase
set -eu
binary=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
here=$(cd "$(dirname "$0")" && pwd)
out=$here/terminal-phase.cast
home=$(mktemp -d)
trap 'tmux -L avrec kill-server 2>/dev/null; rm -rf "$home"' EXIT
cd "$home"  # nothing in the recording names a local path
unset PLTADDONDIR
export HOME="$home" TERM=xterm-256color COLORTERM=truecolor LANG=C.UTF-8
tmux -L avrec -f /dev/null new-session -d -s rec -x 100 -y 30 "$binary" \; set -g status off
python3 -I "$here/drive.py" avrec rec 40 &
drive=$!
asciinema rec --headless --overwrite -q \
  --window-size 100x30 --idle-time-limit 2 \
  --capture-env "TERM,COLORTERM,LANG" --title "Terminal Phase" \
  --command "tmux -L avrec attach -t rec" "$out"
wait "$drive"
