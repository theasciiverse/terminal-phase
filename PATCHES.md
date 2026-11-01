# Changes from upstream

This is the Asciiverse packaging of [Terminal Phase](https://gitlab.com/dustyweb/terminal-phase)
by Christine Lemmer-Webber (GPL-3.0-or-later, `LICENSE.txt`), a space
shooter for the terminal and a test program for Spritely Goblins.
Upstream is the `upstream` remote. Upstream has since moved the game to
Guile (1.2 and later, on `master`); this build is the Racket version, at
`da680c5` (2021-12-26), the last commit before the move: release 1.1 plus
the fixes and new enemies that came after it (mines, upbeam shooters, the
up-cannon) and the updated supporter credits. The `asciiverse` branch
carries the changes below.

## Code

- `pwd.rkt`, `main-menu.rkt`, `credits.rkt`: the game found its levels
  and credits through a runtime path to its whole source folder, which
  makes `raco distribute` copy that folder (sources, `.git` and all)
  into the build. It now names the two things it reads, `levels/` and
  `credits-roll.txt`. Behaviour is unchanged.

## Packaging

- `asciiverse/build.sh`: a standalone program with `raco exe` and
  `raco distribute`, the Racket runtime bundled, plus the two native
  helpers its terminal libraries load (`ansi`, `unix-signals`).
- `asciiverse/stage.sh` and `asciiverse/terminal-phase`: the av archive,
  a start script on top of `bin/` and `lib/`.
- `.github/workflows/asciiverse-release.yml`: av archives for Linux
  (x86-64 and ARM64) and macOS (Intel and Apple silicon), plus
  SHA256SUMS. No Windows build: the terminal libraries are Unix only.
- `asciiverse/record-preview.sh` and `asciiverse/drive.py`: the catalog
  preview, level 1 flown by a script.
