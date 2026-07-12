<div align="center">

# 📁 sortd

**A zero-dependency shell utility that sorts chaotic directories into tidy category sub-folders.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Shell: POSIX sh](https://img.shields.io/badge/Shell-POSIX%20sh-89e051.svg)](#)
[![Version](https://img.shields.io/badge/version-2.0.0-orange.svg)](#)
[![CI](https://github.com/royalturd/sortd/actions/workflows/ci.yml/badge.svg)](https://github.com/royalturd/sortd/actions/workflows/ci.yml)

</div>

---

## Features

- **Interactive directory picker** — numbered menu of common dirs, with a "browse all" mode that leverages `fzf` when available
- **Real-time progress bar** — Unicode block characters in UTF-8 terminals, ASCII fallback elsewhere
- **Duplicate safeguard** — appends a `_YYYYMMDD_HHMMSS` timestamp instead of silently overwriting
- **Force mode** — explicitly opt-in to overwrite duplicates
- **Dry-run mode** — preview every action before committing
- **Verbose mode** — print each `MOVE`, `RENAME`, or `OVERWRITE` as it happens
- **Self-aware** — skips itself if the script lives inside the target directory
- **Safe cleanup** — `trap` removes temp files even on Ctrl-C or unexpected exits
- **No dependencies** — pure POSIX `sh`; `fzf` is optional

---

## File Categories

| Folder          | Extensions |
|-----------------|------------|
| `Documents`     | `.md` `.txt` `.pdf` `.rtf` `.doc` `.docx` `.odt` |
| `Spreadsheets`  | `.csv` `.xls` `.xlsx` `.ods` |
| `Presentations` | `.ppt` `.pptx` `.odp` |
| `Code`          | `.json` `.xml` `.yaml` `.yml` `.html` `.css` `.js` `.ts` `.py` `.sh` `.c` `.cpp` `.go` `.rs` `.java` `.rb` `.php` `.swift` `.kt` `.lua` `.r` `.pl` `.toml` `.ini` `.cfg` `.env` |
| `Images`        | `.jpg` `.jpeg` `.png` `.gif` `.svg` `.webp` `.bmp` `.ico` `.psd` `.ai` `.tiff` `.heic` `.avif` `.raw` `.cr2` `.nef` |
| `Audio`         | `.mp3` `.wav` `.flac` `.m4a` `.ogg` `.aac` `.opus` `.wma` `.aiff` |
| `Videos`        | `.mp4` `.mkv` `.mov` `.avi` `.wmv` `.flv` `.webm` `.m4v` `.3gp` |
| `Archives`      | `.zip` `.tar` `.gz` `.rar` `.7z` `.tgz` `.bz2` `.xz` `.zst` `.lz4` |
| `Packages`      | `.deb` `.rpm` `.pkg` `.dmg` `.msi` `.exe` `.appimage` `.flatpak` `.snap` |
| `Other`         | Everything else |

---

## Installation

### One-liner (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/royalturd/sortd/main/install.sh | sh
```

Or with `wget`:

```bash
wget -qO- https://raw.githubusercontent.com/royalturd/sortd/main/install.sh | sh
```

Installs to `~/.local/bin/sortd` by default. Override the directory:

```bash
INSTALL_DIR=/usr/local/bin curl -fsSL https://raw.githubusercontent.com/royalturd/sortd/main/install.sh | sh
```

### bpkg

```bash
bpkg install royalturd/sortd
```

### Basher

```bash
basher install royalturd/sortd
```

### Manual

```bash
git clone https://github.com/royalturd/sortd.git
cd sortd
chmod +x sortd.sh install.sh
cp sortd.sh ~/.local/bin/sortd
```

---

## Usage

### Interactive mode

Running without arguments opens a directory picker:

```bash
sortd
```

```
sortd — select a directory to organize

  1) /home/user/Downloads
  2) /home/user/Desktop
  3) /home/user/Documents
  a) Browse all directories
  m) Enter path manually

Choice:
```

Choosing **`a`** opens a fuzzy `fzf` browser (if installed) or a full numbered list of every directory under `$HOME`.

---

### Direct mode

```bash
sortd ~/Downloads
```

### Dry-run — preview without moving anything

```bash
sortd ~/Downloads --dry-run
```

### Verbose — print every action

```bash
sortd ~/Downloads --verbose
```

### Force — overwrite duplicates instead of timestamping

```bash
sortd ~/Downloads --force
```

### Combine flags

```bash
sortd ~/Downloads -nv    # dry-run + verbose: full preview
sortd ~/Downloads -fv    # force  + verbose: overwrite with log
```

---

## Options

| Flag | Long form | Description |
|------|-----------|-------------|
| `-f` | `--force` | Overwrite existing files instead of renaming with a timestamp |
| `-n` | `--dry-run` | Preview all actions; no files are moved |
| `-v` | `--verbose` | Print each `MOVE` / `RENAME` / `OVERWRITE` action |
| `-h` | `--help` | Show help and exit |

---

## Requirements

| Tool | Required | Notes |
|------|----------|-------|
| `sh` | ✅ Yes | Any POSIX-compatible shell |
| `find` | ✅ Yes | Standard on all Unix-like systems |
| `fzf` | ⬜ Optional | Enables the fuzzy directory browser |

---

## License

[MIT](LICENSE)
