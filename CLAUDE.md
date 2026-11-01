# Terminal Phase (Asciiverse packaging)

Christine Lemmer-Webber's Terminal Phase (Racket, GPL-3.0-or-later), a
side-scrolling space shooter, packaged for the Asciiverse catalog (id
`terminal-phase`, kind `game`). Not our code: keep changes small and list
every one in PATCHES.md.

- `upstream` is gitlab.com/dustyweb/terminal-phase. Upstream `master` is a
  Guile rewrite (1.2+, Guile 3, guile-ncurses, guile-goblins), hard to
  bundle; we package the Racket version. Branch `asciiverse` starts at
  `da680c5`, the last Racket commit (the next, 8776085, renames the files
  to .scm). Revisit if the Guile version gets a release that bundles.
- Build: `sh asciiverse/build.sh && sh asciiverse/stage.sh` (Racket 8 CS;
  installs lux, goblins, pk, raart, ansi with raco; set PLTADDONDIR to
  keep them out of your own Racket). Run `stage/terminal-phase`.
- ansi and unix-signals load native libraries through
  `(collection-path ...)`; build.sh copies their `private/compiled/native`
  folders in with `raco distribute ++collects-copy`. Without them the
  standalone build fails at start with "collection not found".
- Release: tag `v1.1+20211226-av.<n>` and push it. Linux (-gnu, Racket's
  runtime needs glibc) and macOS; no Windows.
- The game needs 60x22 and says so when smaller.
- Preview: `asciiverse/record-preview.sh stage/bin/terminal-phase`
  (asciinema 3, tmux): drive.py fires, chases enemy rows and dodges; about
  50 s, usually losing two lives.
