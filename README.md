# organize-me 📁

An ultra-lightweight shell utility that automatically organizes chaotic directories into neatly structured category folders. It features a responsive Terminal User Interface (TUI), dynamic progress calculations, duplicate safeguards, a dry-run preview mode, and a force-overwrite mode.

## 🚀 Features

- **Dynamic Selection**: Pass a directory as an argument, or let the interactive prompt guide you with path expansion support.
- **TUI & Progress Bar**: Real-time in-place updating progress meter with Unicode block characters in UTF-8 terminals.
- **Smart Duplicate Safe-Guard**: Prevents accidental data loss by appending unique `_YYYYMMDD_HHMMSS` timestamps to matching filenames.
- **Force Mode (`-f` / `--force`)**: Skip the safeguard and cleanly overwrite existing duplicates.
- **Dry-Run Mode (`-n` / `--dry-run`)**: Preview exactly what *would* be moved without touching a single file.
- **Verbose Mode (`-v` / `--verbose`)**: Print each file action (move / rename / overwrite) as it happens.
- **Self-Aware**: Automatically skips the script itself if it lives inside the target directory.
- **Comprehensive File Mapping**: Categorizes dozens of file types out of the box.
- **Safe Cleanup**: Uses a `trap` to remove temp files even on Ctrl-C or unexpected exits.

## 🛠️ File Organization Rules

The script automatically maps files into the following directories:

| Folder        | File Extensions |
|---------------|-----------------|
| Documents     | `.md` `.txt` `.pdf` `.rtf` `.doc` `.docx` `.odt` |
| Spreadsheets  | `.csv` `.xls` `.xlsx` `.ods` |
| Presentations | `.ppt` `.pptx` `.odp` |
| Code          | `.json` `.xml` `.yaml` `.yml` `.html` `.css` `.js` `.ts` `.py` `.sh` `.c` `.cpp` `.go` `.rs` `.java` `.rb` `.php` `.swift` `.kt` `.lua` `.r` `.pl` `.toml` `.ini` `.cfg` `.env` |
| Images        | `.jpg` `.jpeg` `.png` `.gif` `.svg` `.webp` `.bmp` `.ico` `.psd` `.ai` `.tiff` `.heic` `.avif` `.raw` `.cr2` `.nef` |
| Audio         | `.mp3` `.wav` `.flac` `.m4a` `.ogg` `.aac` `.opus` `.wma` `.aiff` |
| Videos        | `.mp4` `.mkv` `.mov` `.avi` `.wmv` `.flv` `.webm` `.m4v` `.3gp` |
| Archives      | `.zip` `.tar` `.gz` `.rar` `.7z` `.tgz` `.bz2` `.xz` `.zst` `.lz4` |
| Packages      | `.deb` `.rpm` `.pkg` `.dmg` `.msi` `.exe` `.appimage` `.flatpak` `.snap` |
| Other         | Everything else |

## 📦 Installation

To make the script globally executable on your system:

1. Clone or download the script file.
2. Make it executable:
   ```bash
   chmod +x organize-me
   ```
3. Move it to a directory in your system `$PATH` (e.g., `~/.local/bin` or `/usr/local/bin`):
   ```bash
   mv organize-me ~/.local/bin/
   ```

## 💡 Usage

### Interactive Mode

Run the tool directly to be prompted for a directory:

```bash
organize-me
```

### Direct Target Mode

Pass the directory path as the first parameter:

```bash
organize-me ~/Downloads
```

### Dry-Run Mode

Preview what would happen without moving anything:

```bash
organize-me ~/Downloads --dry-run
# Short form:
organize-me ~/Downloads -n
```

### Verbose Mode

Print each file action as it occurs:

```bash
organize-me ~/Downloads --verbose
# Combine with dry-run for a full preview:
organize-me ~/Downloads -n -v
```

### Force Overwrite Mode

Overwrite existing files in target folders instead of renaming with a timestamp:

```bash
organize-me ~/Downloads -f
# OR
organize-me ~/Downloads --force
```

## ⚙️ All Options

```
Usage: organize-me [DIRECTORY] [OPTIONS]

Options:
  -f, --force     Overwrite existing files instead of timestamping duplicates.
  -n, --dry-run   Preview what would be moved; no files are touched.
  -v, --verbose   Print each file action as it happens.
  -h, --help      Show this help message and exit.
```
