#!/bin/sh
# =============================================================================
# sortd — sort a messy directory into tidy category sub-folders
# https://github.com/royalturd/sortd
# =============================================================================

set -e

# ---------------------------------------------------------------------------
# Constants & defaults
# ---------------------------------------------------------------------------

VERSION="2.0.0"
FORCE_MODE=false
DRY_RUN=false
VERBOSE=false
TARGET_DIR=""
FILELIST=""

# ---------------------------------------------------------------------------
# Cleanup
# ---------------------------------------------------------------------------

# shellcheck disable=SC2317
cleanup() { rm -f "$FILELIST"; }
trap cleanup EXIT INT TERM

# ---------------------------------------------------------------------------
# Colors (disabled when stdout is not a terminal)
# ---------------------------------------------------------------------------

if [ -t 1 ]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[1;34m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; DIM=''; NC=''
fi

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------

die()           { printf "%b\n" "${RED}Error:${NC} $1" >&2; exit 1; }
warn()          { printf "%b\n" "${YELLOW}Warning:${NC} $1" >&2; }
info()          { printf "%b\n" "${BLUE}$1${NC}"; }
ok()            { printf "%b\n" "${GREEN}$1${NC}"; }
verbose()       { [ "$VERBOSE" = true ] && printf "%b\n" "${DIM}  $1${NC}"; return 0; }

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------

usage() {
    cat <<EOF
${BOLD}sortd${NC} v${VERSION} — sort a directory into category sub-folders

${BOLD}Usage:${NC}
  sortd [DIRECTORY] [OPTIONS]

${BOLD}Options:${NC}
  -f, --force     Overwrite existing files instead of timestamping duplicates
  -n, --dry-run   Preview changes without moving any files
  -v, --verbose   Print each file action as it happens
  -h, --help      Show this help message and exit

${BOLD}Examples:${NC}
  sortd
  sortd ~/Downloads
  sortd ~/Downloads --dry-run
  sortd ~/Downloads -fv
EOF
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

while [ "$#" -gt 0 ]; do
    case "$1" in
        -f|--force)   FORCE_MODE=true ;;
        -n|--dry-run) DRY_RUN=true ;;
        -v|--verbose) VERBOSE=true ;;
        -h|--help)    usage; exit 0 ;;
        --)           shift; break ;;
        -*)
            printf "%b\n" "${RED}Error:${NC} Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
        *)
            [ -n "$TARGET_DIR" ] && die "Unexpected argument '$1' (directory already set to '$TARGET_DIR')"
            TARGET_DIR="$1"
            ;;
    esac
    shift
done

# ---------------------------------------------------------------------------
# Interactive directory picker
# ---------------------------------------------------------------------------

_menu_pick() {
    listfile=$1
    total=$(wc -l < "$listfile" | tr -d ' ')
    i=1
    while [ "$i" -le "$total" ]; do
        printf "  %b%d)%b %s\n" "$BOLD" "$i" "$NC" "$(sed -n "${i}p" "$listfile")"
        i=$((i + 1))
    done
    printf "\n"
    printf "Choice (number): "
    read -r pick
    if [ -n "$pick" ] && [ "$pick" -ge 1 ] 2>/dev/null && [ "$pick" -le "$total" ] 2>/dev/null; then
        sed -n "${pick}p" "$listfile"
    fi
}

_browse_all() {
    tmpfile=$(mktemp 2>/dev/null) || return
    find "$HOME" -maxdepth 3 -type d ! -name ".*" 2>/dev/null | sort > "$tmpfile"

    if command -v fzf >/dev/null 2>&1; then
        result=$(fzf \
            --prompt="  Directory: " \
            --height=60% \
            --border=rounded \
            --header=" Browse all  |  Enter: select  |  Esc: cancel" \
            --preview="ls --color=always {}" \
            --preview-window=right:45%:border-left \
            < "$tmpfile" 2>/dev/null)
    else
        printf "\n%b\n\n" "${BOLD}All directories under $HOME (depth 3):${NC}"
        result=$(_menu_pick "$tmpfile")
    fi

    rm -f "$tmpfile"
    printf '%s' "$result"
}

_select_directory() {
    tmpfile=$(mktemp 2>/dev/null) || return

    for candidate in \
        "$HOME/Downloads" \
        "$HOME/Desktop"   \
        "$HOME/Documents" \
        "$HOME/Pictures"  \
        "$HOME/Videos"    \
        "$HOME/Music"     \
        "$(pwd)"
    do
        [ -d "$candidate" ] && printf '%s\n' "$candidate" >> "$tmpfile"
    done

    total=$(wc -l < "$tmpfile" | tr -d ' ')

    printf "\n%b\n\n" "${BOLD}sortd${NC} — select a directory to organize"

    i=1
    while [ "$i" -le "$total" ]; do
        printf "  %b%d)%b %s\n" "$BOLD" "$i" "$NC" "$(sed -n "${i}p" "$tmpfile")"
        i=$((i + 1))
    done
    printf "  %ba)%b Browse all directories\n" "$BOLD" "$NC"
    printf "  %bm)%b Enter path manually\n\n" "$BOLD" "$NC"
    printf "Choice: "
    read -r choice

    case "$choice" in
        a) result=$(_browse_all) ;;
        m)
            printf "Path: "
            read -r result
            ;;
        *)
            if [ -n "$choice" ] && [ "$choice" -ge 1 ] 2>/dev/null && [ "$choice" -le "$total" ] 2>/dev/null; then
                result=$(sed -n "${choice}p" "$tmpfile")
            fi
            ;;
    esac

    rm -f "$tmpfile"
    printf '%s' "${result:-}"
}

# ---------------------------------------------------------------------------
# Resolve target directory
# ---------------------------------------------------------------------------

if [ -z "$TARGET_DIR" ]; then
    clear
    TARGET_DIR=$(_select_directory)
    [ -z "$TARGET_DIR" ] && die "No directory provided. Aborting."
fi

case "$TARGET_DIR" in
    # shellcheck disable=SC2088
    "~")    TARGET_DIR="$HOME" ;;
    # shellcheck disable=SC2088
    "~/"*)  TARGET_DIR="$HOME/${TARGET_DIR#~/}" ;;
esac

[ -d "$TARGET_DIR" ] || die "'$TARGET_DIR' is not a valid directory."
[ -w "$TARGET_DIR" ] || die "No write permission for '$TARGET_DIR'."

TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd) || die "Could not resolve target directory."

# ---------------------------------------------------------------------------
# Category mapping
# ---------------------------------------------------------------------------

category_for_ext() {
    case "$1" in
        md|txt|pdf|rtf|doc|docx|odt)                                         echo "Documents"     ;;
        csv|xls|xlsx|ods)                                                     echo "Spreadsheets"  ;;
        ppt|pptx|odp)                                                         echo "Presentations" ;;
        json|xml|yaml|yml|html|css|js|ts|py|sh|c|cpp|go|rs|java|\
rb|php|swift|kt|lua|r|pl|toml|ini|cfg|env)                                   echo "Code"          ;;
        jpg|jpeg|png|gif|svg|webp|bmp|ico|psd|ai|tiff|tif|heic|heif|\
avif|raw|cr2|nef)                                                             echo "Images"        ;;
        mp3|wav|flac|m4a|ogg|aac|opus|wma|aiff)                              echo "Audio"         ;;
        mp4|mkv|mov|avi|wmv|flv|webm|m4v|3gp)                               echo "Videos"        ;;
        zip|tar|gz|rar|7z|tgz|bz2|xz|zst|lz4)                              echo "Archives"       ;;
        deb|rpm|pkg|dmg|msi|exe|appimage|flatpak|snap)                       echo "Packages"      ;;
        *)                                                                    echo "Other"         ;;
    esac
}

# ---------------------------------------------------------------------------
# Build file list (top-level, non-hidden, skip the script itself)
# ---------------------------------------------------------------------------

FILELIST=$(mktemp 2>/dev/null) || die "Cannot create temp file."
SELF=$(cd "$(dirname "$0")" 2>/dev/null && pwd)/$(basename "$0")

find "$TARGET_DIR" -maxdepth 1 -type f ! -name ".*" | while IFS= read -r f; do
    canonical=$(cd "$(dirname "$f")" 2>/dev/null && pwd)/$(basename "$f")
    [ "$canonical" = "$SELF" ] && continue
    printf '%s\n' "$f"
done > "$FILELIST"

TOTAL=$(wc -l < "$FILELIST" | tr -d ' ')

if [ "$TOTAL" -eq 0 ]; then
    info "Nothing to organize in '$TARGET_DIR'."
    exit 0
fi

info "Found $TOTAL file(s) in '$TARGET_DIR'. Starting…"
[ "$FORCE_MODE" = true ] && info "Force mode  — duplicates will be overwritten."
[ "$DRY_RUN"   = true ] && warn "Dry-run mode — no files will be moved."

# ---------------------------------------------------------------------------
# Progress bar
# ---------------------------------------------------------------------------

if [ "$(locale charmap 2>/dev/null)" = "UTF-8" ]; then
    BAR_FILL="█"; BAR_EMPTY="░"
else
    BAR_FILL="#"; BAR_EMPTY="-"
fi

show_progress() {
    cur=$1 total=$2 width=40
    pct=$((cur * 100 / total))
    filled=$((cur * width / total))
    empty=$((width - filled))

    bar=""; i=0
    while [ "$i" -lt "$filled" ]; do bar="${bar}${BAR_FILL}"; i=$((i+1)); done
    pad=""; i=0
    while [ "$i" -lt "$empty" ];  do pad="${pad}${BAR_EMPTY}"; i=$((i+1)); done

    printf "\r%bProgress:%b [%s%s] %3d%% (%d/%d)" \
        "$BOLD" "$NC" "$bar" "$pad" "$pct" "$cur" "$total"
}

# ---------------------------------------------------------------------------
# Process files
# ---------------------------------------------------------------------------

count=0; moved=0; errors=0

while IFS= read -r filepath; do
    count=$((count + 1))
    filename=$(basename "$filepath")

    case "$filename" in
        *.*) ext=$(printf '%s' "${filename##*.}" | tr '[:upper:]' '[:lower:]') ;;
        *)   ext="" ;;
    esac

    category=$(category_for_ext "$ext")
    dest_dir="$TARGET_DIR/$category"
    dest_path="$dest_dir/$filename"

    if ! mkdir -p "$dest_dir" 2>/dev/null; then
        warn "Cannot create '$dest_dir' — skipping '$filename'."
        errors=$((errors + 1))
        show_progress "$count" "$TOTAL"
        continue
    fi

    if [ -e "$dest_path" ]; then
        if [ "$FORCE_MODE" = true ]; then
            if [ "$DRY_RUN" = true ]; then
                verbose "[dry-run] OVERWRITE  $filename  →  $category/"
            elif mv -f -- "$filepath" "$dest_path" 2>/dev/null; then
                verbose "OVERWRITE  $filename  →  $category/"
            else
                warn "Failed to overwrite '$filename'."; errors=$((errors + 1))
                show_progress "$count" "$TOTAL"; continue
            fi
        else
            ts=$(date +%Y%m%d_%H%M%S)
            case "$filename" in
                *.*) newname="${filename%.*}_${ts}.${ext}" ;;
                *)   newname="${filename}_${ts}" ;;
            esac
            if [ "$DRY_RUN" = true ]; then
                verbose "[dry-run] RENAME  $filename  →  $category/$newname"
            elif mv -- "$filepath" "$dest_dir/$newname" 2>/dev/null; then
                verbose "RENAME  $filename  →  $category/$newname"
            else
                warn "Failed to rename '$filename'."; errors=$((errors + 1))
                show_progress "$count" "$TOTAL"; continue
            fi
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            verbose "[dry-run] MOVE  $filename  →  $category/"
        elif mv -- "$filepath" "$dest_path" 2>/dev/null; then
            verbose "MOVE  $filename  →  $category/"
        else
            warn "Failed to move '$filename'."; errors=$((errors + 1))
            show_progress "$count" "$TOTAL"; continue
        fi
    fi

    moved=$((moved + 1))
    show_progress "$count" "$TOTAL"
done < "$FILELIST"

printf "\n"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

if [ "$DRY_RUN" = true ]; then
    ok "Dry-run complete.  Would move: $moved  |  Errors: $errors  |  Total: $TOTAL"
else
    ok "Done.  Moved: $moved  |  Errors: $errors  |  Total: $TOTAL"
fi

[ "$errors" -gt 0 ] && exit 1
exit 0
