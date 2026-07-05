# organize-me 📁

An ultra-lightweight shell utility that automatically organizes chaotic directories into neatly structured category folders. It features a responsive Terminal User Interface (TUI), dynamic progress calculations, duplicate safeguards, and a force-overwrite mode.

## 🚀 Features

- **Dynamic Selection**: Pass a directory as an argument, or let the interactive prompt guide you with path expansion support.
- **TUI & Progress Bar**: Real-time updates inside your terminal via an in-place updating progress meter.
- **Smart Duplicate Safe-Guard**: Prevents accidental data loss by appending unique `_YYYYMMDD_HHMMSS` timestamps to matching filenames.
- **Force Mode (`-f` / `--force`)**: Skip the safeguard and cleanly overwrite existing duplicates to forcefully re-organize files.
- **Comprehensive File Mapping**: Categorizes dozens of file types out of the box (Documents, Spreadsheets, Presentations, Code, Images, Audio, Videos, Archives, and Packages).

## 🛠️ File Organization Rules

The script automatically maps files into the following directories:

| Folder | File Extensions |
|---|---|
| Documents | `.md`, `.txt`, `.pdf`, `.rtf`, `.doc`, `.docx`, `.odt` |
| Spreadsheets | `.csv`, `.xls`, `.xlsx`, `.ods` |
| Presentations | `.ppt`, `.pptx`, `.odp` |
| Code | `.json`, `.xml`, `.yaml`, `.yml`, `.html`, `.css`, `.js`, `.ts`, `.py`, `.sh`, `.c`, `.cpp`, `.go`, `.rs`, `.java` |
| Images | `.jpg`, `.jpeg`, `.png`, `.gif`, `.svg`, `.webp`, `.bmp`, `.ico`, `.psd`, `.ai` |
| Audio | `.mp3`, `.wav`, `.flac`, `.m4a`, `.ogg`, `.aac` |
| Videos | `.mp4`, `.mkv`, `.mov`, `.avi`, `.wmv`, `.flv` |
| Archives | `.zip`, `.tar`, `.gz`, `.rar`, `.7z`, `.tgz` |
| Packages | `.deb`, `.rpm`, `.pkg`, `.dmg`, `.msi`, `.exe` |

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

### Force Overwrite Mode

Force the organization process, overwriting existing files in target folders instead of renaming them:

```bash
organize-me ~/Downloads -f
# OR
organize-me ~/Downloads --force
```
