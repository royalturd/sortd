#!/bin/sh
# organize-me - organizes a chaotic directory into category folders

FORCE_MODE=false
TARGET_DIR=""

# --- Color setup (only if stdout is a terminal) ---
if [ -t 1 ]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

print_error()   { printf "%b\n" "${RED}Error:${NC} $1" >&2; }
print_ok()      { printf "%b\n" "${GREEN}$1${NC}"; }
print_info()    { printf "%b\n" "${BLUE}$1${NC}"; }

show_help() {
    cat <<'EOF'
Usage: organize-me [DIRECTORY] [OPTIONS]

Organizes files in DIRECTORY into category subfolders
(Documents, Spreadsheets, Presentations, Code, Images, Audio,
Videos, Archives, Packages, Other).

If DIRECTORY is omitted, you will be prompted interactively.

Options:
  -f, --force     Overwrite existing files in destination folders
                   instead of appending a timestamp to duplicates.
  -h, --help      Show this help message and exit.

Examples:
  organize-me
  organize-me ~/Downloads
  organize-me ~/Downloads -f
  organize-me ~/Downloads --force
EOF
}

# --- 1. Parse Command Line Arguments ---
while [ "$#" -gt 0 ]; do
    case "$1" in
        -f|--force)
            FORCE_MODE=true
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            print_error "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -n "$TARGET_DIR" ]; then
                print_error "Unexpected extra argument: $1 (target already set to '$TARGET_DIR')"
                exit 1
            fi
            TARGET_DIR="$1"
            ;;
    esac
    shift
done

# --- 2. Directory Selection Prompt (if not passed as argument) ---
if [ -z "$TARGET_DIR" ]; then
    clear
    printf "%b\n" "${BOLD}organize-me${NC} - interactive directory organizer"
    printf "%b" "Enter the directory path to organize (supports ~ expansion): "
    read -r TARGET_DIR

    if [ -z "$TARGET_DIR" ]; then
        print_error "No directory provided. Aborting."
        exit 1
    fi
fi

# --- 3. Expand leading ~ manually (POSIX sh does not expand ~ from a variable) ---
case "$TARGET_DIR" in
    "~")
        TARGET_DIR="$HOME"
        ;;
    "~/"*)
        TARGET_DIR="$HOME/${TARGET_DIR#~/}"
        ;;
esac

# --- 4. Validate target directory ---
if [ ! -d "$TARGET_DIR" ]; then
    print_error "'$TARGET_DIR' is not a valid directory."
    exit 1
fi

if [ ! -w "$TARGET_DIR" ]; then
    print_error "No write permission for '$TARGET_DIR'."
    exit 1
fi

# Resolve to an absolute path so we don't get confused mid-run
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd)
if [ -z "$TARGET_DIR" ]; then
    print_error "Could not resolve target directory."
    exit 1
fi

# --- 5. Category mapping ---
category_for_ext() {
    ext=$1
    case "$ext" in
        md|txt|pdf|rtf|doc|docx|odt)
            echo "Documents" ;;
        csv|xls|xlsx|ods)
            echo "Spreadsheets" ;;
        ppt|pptx|odp)
            echo "Presentations" ;;
        json|xml|yaml|yml|html|css|js|ts|py|sh|c|cpp|go|rs|java)
            echo "Code" ;;
        jpg|jpeg|png|gif|svg|webp|bmp|ico|psd|ai)
            echo "Images" ;;
        mp3|wav|flac|m4a|ogg|aac)
            echo "Audio" ;;
        mp4|mkv|mov|avi|wmv|flv)
            echo "Videos" ;;
        zip|tar|gz|rar|7z|tgz)
            echo "Archives" ;;
        deb|rpm|pkg|dmg|msi|exe)
            echo "Packages" ;;
        *)
            echo "Other" ;;
    esac
}

# --- 6. Build the list of files to process (top-level files only, skip dirs/dotfiles/self) ---
# Using a temp file instead of an array (POSIX sh has no arrays).
FILELIST=$(mktemp 2>/dev/null || echo "/tmp/organize-me.$$")
: > "$FILELIST"

# Avoid glob issues with hidden files or empty dirs by using find (depth 1, files only)
find "$TARGET_DIR" -maxdepth 1 -type f ! -name ".*" -print > "$FILELIST"

TOTAL=$(wc -l < "$FILELIST" | tr -d ' ')

if [ "$TOTAL" -eq 0 ]; then
    print_info "Nothing to organize in '$TARGET_DIR'."
    rm -f "$FILELIST"
    exit 0
fi

print_info "Found $TOTAL file(s) in '$TARGET_DIR'. Starting organization..."
[ "$FORCE_MODE" = true ] && print_info "Force mode enabled: existing duplicates will be overwritten."

# --- 7. Progress bar helper ---
if [ "$(locale charmap 2>/dev/null)" = "UTF-8" ]; then
    BAR_FULL="#"
    BAR_EMPTY="-"
else
    BAR_FULL="#"
    BAR_EMPTY="-"
fi

show_progress() {
    current=$1
    total=$2
    width=40
    percentage=$((current * 100 / total))
    completed=$((current * width / total))
    remaining=$((width - completed))

    bar=""
    i=0
    while [ "$i" -lt "$completed" ]; do bar="${bar}${BAR_FULL}"; i=$((i + 1)); done
    space=""
    i=0
    while [ "$i" -lt "$remaining" ]; do space="${space}${BAR_EMPTY}"; i=$((i + 1)); done

    printf "\r%bProgress: [%s%s] %d%% (%d/%d)%b" "$BLUE" "$bar" "$space" "$percentage" "$current" "$total" "$NC"
}

# --- 8. Process files ---
count=0
moved=0
skipped=0
errors=0

while IFS= read -r filepath; do
    count=$((count + 1))
    filename=$(basename "$filepath")

    # Extract extension (lowercased), handle files with no extension
    case "$filename" in
        *.*)
            ext=$(printf '%s' "${filename##*.}" | tr '[:upper:]' '[:lower:]')
            ;;
        *)
            ext=""
            ;;
    esac

    category=$(category_for_ext "$ext")
    dest_dir="$TARGET_DIR/$category"
    dest_path="$dest_dir/$filename"

    if ! mkdir -p "$dest_dir" 2>/dev/null; then
        errors=$((errors + 1))
        show_progress "$count" "$TOTAL"
        continue
    fi

    if [ -e "$dest_path" ]; then
        if [ "$FORCE_MODE" = true ]; then
            if mv -f -- "$filepath" "$dest_path" 2>/dev/null; then
                moved=$((moved + 1))
            else
                errors=$((errors + 1))
            fi
        else
            timestamp=$(date +%Y%m%d_%H%M%S)
            base="${filename%.*}"
            case "$filename" in
                *.*) newname="${base}_${timestamp}.${ext}" ;;
                *)   newname="${filename}_${timestamp}" ;;
            esac
            if mv -- "$filepath" "$dest_dir/$newname" 2>/dev/null; then
                moved=$((moved + 1))
            else
                errors=$((errors + 1))
            fi
        fi
    else
        if mv -- "$filepath" "$dest_path" 2>/dev/null; then
            moved=$((moved + 1))
        else
            errors=$((errors + 1))
        fi
    fi

    show_progress "$count" "$TOTAL"
done < "$FILELIST"

printf "\n"
rm -f "$FILELIST"

# --- 9. Summary ---
print_ok "Done. Moved: $moved  Errors: $errors  Total: $TOTAL"

if [ "$errors" -gt 0 ]; then
    exit 1
fi

exit 0
