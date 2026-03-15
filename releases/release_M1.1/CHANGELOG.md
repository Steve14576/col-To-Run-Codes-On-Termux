# CHANGELOG

## [M1.1] — 2026-03-15

> M model
> Language: Chinese, English, Klingon

Incremental update focusing on configuration management and user experience improvements.

### Included Files

- `colM1.1_Chn.sh` (Chinese UI)
- `colM1.1_Eng.sh` (English UI)
- `colM1.1_Kli.sh` (Klingon UI)
- `README.md`

### New Features

- **Seed Persistence**: New `save`/`reset` commands to persist configuration directly into the script's built-in `# [COL_SEED]` header.
- **Startup Seed REPL**: Interactive seed configuration prompt on startup (press Enter twice to skip).
- **`status` Command**: Replaces `checkavails` with comprehensive status overview including paths, compiler availability, and stored seed.
- **Enhanced `vcd`**: Streamlined virtual directory management with `-` flag to clear VTARGET.

### Improvements

- **Session Restoration**: Built-in seed storage allows automatic restoration of previous session configuration.
- **Seed Conflict Detection**: Startup banner now shows warning when current paths differ from stored seed.
- **Configuration UX**: Two-step seed input with visual feedback and screen cleanup for cleaner interface.

### Migration from M1.0

| M1.0                   | M1.1                    |
| ---------------------- | ----------------------- |
| `checkavails`        | `status` (enhanced)   |
| Manual seed copy-paste | `save` command        |
| Direct startup         | Seed configuration REPL |

### Compatibility

- Fully backward compatible with M1.0 config seeds
- Same language support: 12 languages (C, C++, Java, Python, Shell, JS, PHP, Octave, Fortran, Rust, Kotlin, Go)
