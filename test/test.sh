#!/bin/sh
# test/test.sh — basic smoke tests for sortd

SORTD="$(cd "$(dirname "$0")/.." && pwd)/sortd.sh"
PASS=0; FAIL=0

assert_eq() {
    label=$1; expected=$2; actual=$3
    if [ "$actual" = "$expected" ]; then
        printf "  \033[1;32mPASS\033[0m  %s\n" "$label"
        PASS=$((PASS + 1))
    else
        printf "  \033[1;31mFAIL\033[0m  %s\n        expected: %s\n        got:      %s\n" \
            "$label" "$expected" "$actual"
        FAIL=$((FAIL + 1))
    fi
}

# --- setup ---
WORK_DIR=$(mktemp -d)
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT INT TERM

touch "$WORK_DIR/report.pdf"
touch "$WORK_DIR/photo.JPG"
touch "$WORK_DIR/archive.tar.gz"
touch "$WORK_DIR/script.py"
touch "$WORK_DIR/noextension"

printf "\n\033[1mRunning sortd tests...\033[0m\n\n"

# dry-run should not move anything
sh "$SORTD" "$WORK_DIR" --dry-run >/dev/null 2>&1
assert_eq "dry-run: no files moved" "5" "$(find "$WORK_DIR" -maxdepth 1 -type f | wc -l | tr -d ' ')"

# real run
sh "$SORTD" "$WORK_DIR" >/dev/null 2>&1
assert_eq "pdf   → Documents/"  "1" "$(find "$WORK_DIR/Documents" -name "*.pdf" | wc -l | tr -d ' ')"
assert_eq "jpg   → Images/"     "1" "$(find "$WORK_DIR/Images"    -name "*.JPG" | wc -l | tr -d ' ')"
assert_eq "gz    → Archives/"   "1" "$(find "$WORK_DIR/Archives"  -name "*.gz"  | wc -l | tr -d ' ')"
assert_eq "py    → Code/"       "1" "$(find "$WORK_DIR/Code"      -name "*.py"  | wc -l | tr -d ' ')"
assert_eq "no ext → Other/"     "1" "$(find "$WORK_DIR/Other"     -name "noext*"| wc -l | tr -d ' ')"

printf "\n\033[1mResults: \033[1;32m%d passed\033[0m  \033[1;31m%d failed\033[0m\n\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
