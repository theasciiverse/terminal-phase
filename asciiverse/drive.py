#!/usr/bin/env python3
"""drive.py SOCKET SESSION [SECONDS]: plays Terminal Phase in a tmux pane.

Starts a game from the menu, then several times a second reads the
playfield from the pane: the ship is the '>', terrain is '#', the
starfield is Braille dots, and anything else ahead of the ship is an
enemy or its fire. The ship keeps firing, climbs or dives toward the
nearest enemy row, and steers off any row where something is about to
hit it. After SECONDS (default 40) of play, or at game over, it quits to
the menu with q and leaves the game with q. Run by record-preview.sh
while asciinema records the pane."""
import subprocess, sys, time

SOCK, S = sys.argv[1], sys.argv[2]
PLAY = float(sys.argv[3]) if len(sys.argv) > 3 else 40.0
ENEMY = set("<SnKI^+*|%")

def tmux(*a): return subprocess.run(["tmux", "-L", SOCK, *a], capture_output=True, text=True).stdout
def key(*k): tmux("send-keys", "-t", S, *k)
def pane(): return tmux("capture-pane", "-p", "-t", S).split("\n")

def field(rows):
    """The playfield inside the frame: list of strings, Braille as space."""
    top = next((i for i, l in enumerate(rows) if "┌" in l and "┐" in l), None)
    if top is None: return None, None
    bot = next(i for i in range(top + 1, len(rows)) if "└" in rows[i])
    left = rows[top].index("┌")
    right = rows[top].index("┐")
    out = []
    for l in rows[top + 1:bot]:
        seg = l[left + 1:right].ljust(right - left - 1)
        out.append("".join(" " if "⠀" <= c <= "⣿" else c for c in seg))
    return out, rows

def at(f, r, c):
    return f[r][c] if 0 <= r < len(f) and 0 <= c < len(f[r]) else " "

def danger(f, r, x):
    """How bad row r is for the ship at column x: terrain or anything
    hostile close ahead in the row, or right beside it in the rows next
    door (fire drifts and enemies weave)."""
    if r < 0 or r >= len(f): return 99
    bad = 0
    for dx in range(-1, 9):
        c = at(f, r, x + dx)
        if c == "#" or c in ENEMY: bad += 10 - max(dx, 0)
    for dr in (-1, 1):
        for dx in range(-1, 3):
            if at(f, r + dr, x + dx) in ENEMY: bad += 4
    return bad

def main():
    time.sleep(3)
    key("Enter")
    time.sleep(1.5)
    t0 = time.time()
    shot = 0
    while time.time() - t0 < PLAY:
        f, rows = field(pane())
        if f is None or not any("LIVES" in l for l in rows):
            break  # game over screen or menu
        pos = next(((r, l.index(">")) for r, l in enumerate(f) if ">" in l), None)
        if pos is None:
            time.sleep(0.1); continue
        r, x = pos
        # target: the nearest enemy to the right
        targets = [(c - x, rr) for rr, l in enumerate(f) for c, ch in enumerate(l)
                   if ch in "<SnKI^+" and c > x]
        want = min(targets)[1] if targets else r
        options = [r, r - 1, r + 1]
        options.sort(key=lambda rr: (danger(f, rr, x), abs(rr - want), rr != r))
        best = options[0]
        if best < r: key("Up")
        elif best > r: key("Down")
        if time.time() - shot > 0.25:
            key("Space"); shot = time.time()
        time.sleep(0.08)
    # leave: q ends the level (or a message), q again at the menu quits
    time.sleep(1.5)
    for _ in range(3):
        rows = pane()
        if any("Play game!" in l for l in rows): break
        key("q"); time.sleep(1.5)
    time.sleep(2)
    key("q")

main()
