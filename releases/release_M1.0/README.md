# col — Multi-language Compile & Run Tool for Termux

**col** is a lightweight interactive Bash script that compiles and runs source files on Android via **Termux**.  
It supports 12 languages, auto-detects the compiler from the file extension, and cleans up build artifacts automatically.

Two editions are included:

| File | Language |
|------|----------|
| `colM1_Chn.sh` | 中文界面 |
| `colM1_Eng.sh` | English UI |

---

## Supported Languages

| Language | Default Compiler | Alternatives |
|----------|-----------------|--------------|
| C | clang | gcc, clang |
| C++ | g++ | g++, clang++ |
| Java | javac | javac |
| Python | python3 | python3, pypy, pypy3 |
| Shell | bash | bash, sh |
| JavaScript | node | node |
| PHP | php | php |
| Fortran | gfortran | gfortran |
| Rust | rustc | rustc |
| Kotlin | kotlinc | kotlinc |
| Octave | octave | octave |
| Go | go | go |

---

## Quick Start

```bash
# Make executable
chmod +x colM1_Eng.sh

# Launch with defaults
bash colM1_Eng.sh

# Launch with custom source/output directories
bash colM1_Eng.sh f-./src t-./bin

# Launch with custom compiler mapping
bash colM1_Eng.sh f-./src t-./bin op-gcc-c,g++-cpp

# Show help and exit
bash colM1_Eng.sh --help

# Show version and exit
bash colM1_Eng.sh --version
```

### Startup Parameters (Config Seed)

| Parameter | Description | Example |
|-----------|-------------|---------|
| `f-<path>` | Source file directory | `f-./src` |
| `t-<path>` | Build output directory | `t-./bin` |
| `op-<mapping>` | Compiler–language pairs (comma-separated) | `op-clang-c,g++-cpp` |

---

## Interactive Commands

After launch, you enter the interactive prompt:

```
🟢[colM1_Chn] .../your/dir ❯          # normal mode
🔵[colM1_Chn]🔗 .../virtual/dir ❯    # virtual directory active
```

### Compile & Run

| Input | Effect |
|-------|--------|
| `test.c` | Find `test.c` recursively, compile and run with the default compiler |
| `test.c gcc` | Same, but override the compiler to `gcc` for this run only |
| `1` | Run the file numbered 1 from the last `num` listing |
| `1 clang` | Run file #1, override compiler to `clang` for this run |

### File Browser

| Input | Effect |
|-------|--------|
| `num` | List all supported source files in the source directory (numbered) |
| `vls` | Run `ls` in the current virtual directory (passes extra args to `ls`) |
| `vls -la` | Run `ls -la` in the virtual directory |

### Virtual Directory (v-series)

| Input | Effect |
|-------|--------|
| `vcd <path>` | Set virtual target directory (can point outside `~/`) |
| `vcd` | Show the current virtual directory status |
| `vcd -` | Clear the virtual directory, revert to source directory |

The virtual directory affects both `num` file listing and recursive file search.  
When active, the prompt color changes from 🟢 to 🔵 with a 🔗 indicator.

### Other

| Input | Effect |
|-------|--------|
| `checkavails` | Show installation status and version of all compilers |
| `--help` / `-h` | Show help |
| `--version` / `-v` | Show version |
| `Ctrl+C` | Exit and print the current config seed for reuse next time |

---

## How It Works

1. You type a filename (or number from `num`)
2. The script searches for it recursively under the source directory (up to 5 levels deep)
3. Language is detected from the file extension
4. The appropriate compiler is invoked; compilation status is shown inline (`🔨 Compiling...` → `✅` or `❌`)
5. On success, the binary/class/jar is executed immediately
6. The build artifact is deleted after execution

Interpreted languages (Python, Shell, JavaScript, PHP, Octave) are run directly — no artifact is produced.

---

## Config Seed

When you exit with **Ctrl+C**, the script prints a ready-to-copy command:

```
┌──────────────────────────────────┐
│           Config Seed            │
│  Use this command to reinit:     │
  ./colM1_Eng.sh f-./src t-./bin op-clang-c,g++-cpp
└───────────────────────────────────
```

Paste it next time to restore the exact same configuration instantly.

---

## Install Compilers (Termux)

```bash
pkg install clang        # C / C++
pkg install openjdk-17   # Java
pkg install python       # Python
pkg install nodejs       # JavaScript
pkg install php          # PHP
pkg install gcc-gfortran # Fortran
pkg install rust         # Rust
pkg install kotlin       # Kotlin
pkg install octave       # Octave
pkg install golang       # Go
```

---

## File Structure

```
col-main/
├── colM1_Chn.sh   # Chinese UI edition
├── colM1_Eng.sh   # English UI edition
└── README.md
```

---

## Notes

- Designed for **Termux on Android** (unrooted devices supported)
- Requires **Bash 4+** (`declare -A` associative arrays)
- On FAT32 storage, execute permission cannot be set — run via `bash colM1_Eng.sh` instead of `./colM1_Eng.sh`
- If multiple files share the same name, the script lists all matches and prompts you to choose
