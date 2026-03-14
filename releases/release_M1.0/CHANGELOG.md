# CHANGELOG

## [M1.0] — 2026-03-14

> M model
> Language: Chinese, English, Klingon

Initial release of the **col** series.
A complete restart and re-architecture based on the former `colL5.sh` codebase.

### Included Files

- `colM1_Chn.sh` (Chinese UI)
- `colM1_Eng.sh` (English UI)
- `Dbn.sh` (Easter-egg edition)
- `colM1_Kli.sh` (Klingon UI)
- `README.md`

### Highlights

- **Core**: Supports 12 languages (C, C++, Java, Python, Shell, JS, PHP, Octave, Fortran, Rust, Kotlin, Go) with automatic extension detection.
- **Virtual Directory**: New `vcd`/`vls` commands for managing target directories within termux `~` dir outside the source tree.
- **File Browser**: Added `num` command for interactive, numbered file selection via DFS tree listing.
- **Session State**: Auto-generates config seed on exit (`Ctrl+C`) to restore session state next time.

### Easter Egg

`Dbn.sh` — A *Naked Gun* themed build preserved as a tribute to the colL era. (Functionally equivalent to colL5 baseline).
