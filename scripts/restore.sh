
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

# SAFE RESTORE PREPARATION
# This script verifies an encrypted age archive and lists its contents.
# It does not install software, overwrite application data, or start services.

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 BACKUP_ARCHIVE.age EMPTY_DESTINATION_DIRECTORY" >&2
  exit 2
fi

ARCHIVE="$(realpath "$1")"
DEST="$2"

for cmd in age tar sha256sum realpath; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: Required command missing: $cmd" >&2
    exit 1
  }
done

[[ -f "$ARCHIVE" && -s "$ARCHIVE" ]] || {
  echo "ERROR: Archive does not exist or is empty." >&2
  exit 1
}

if [[ -e "$DEST" ]]; then
  echo "ERROR: Destination already exists. Choose a new empty path." >&2
  exit 1
fi

PARENT="$(dirname "$DEST")"
mkdir -p "$PARENT"
chmod 700 "$PARENT"

WORK="$(mktemp -d "$PARENT/.restore-check.XXXXXX")"
trap 'rm -rf -- "$WORK"' EXIT

echo "Checking archive decryption and readability..."
age -d "$ARCHIVE" | tar -tzf - > "$WORK/archive-list.txt"

echo
echo "Archive is readable. Entry count:"
wc -l < "$WORK/archive-list.txt"

echo
echo "First entries:"
head -n 20 "$WORK/archive-list.txt"

echo
echo "Required components to review:"
grep -E '(^|/)(config.yaml|auth.json|state.db|data.sqlite|hermes-gateway.service|9router-image.tar)$' \
  "$WORK/archive-list.txt" || true

echo
echo "Archive verification completed."
echo "No application data was restored and no services were started."
echo
echo "Destination was not created. Review the archive format and contents"
echo "before implementing the extraction and application-specific restore."
