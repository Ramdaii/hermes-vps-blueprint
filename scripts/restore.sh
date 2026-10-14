```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

# Verifies a required SHA-256 checksum, archive decryption,
# readability, and basic archive paths.
# Does not extract files or start services.

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 BACKUP_ARCHIVE.age DESTINATION_PATH" >&2
  exit 2
fi

INPUT="$1"
DEST="$2"

for cmd in age tar sha256sum realpath python3 mktemp; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: Required command missing: $cmd" >&2
    exit 1
  }
done

[[ -f "$INPUT" && -s "$INPUT" ]] || {
  echo "ERROR: Archive does not exist or is empty." >&2
  exit 1
}

ARCHIVE="$(realpath "$INPUT")"
CHECKSUM="${ARCHIVE}.sha256"

# Refuse an existing destination, including a dangling symlink.
if [[ -e "$DEST" || -L "$DEST" ]]; then
  echo "ERROR: Destination already exists. Choose a new path." >&2
  exit 1
fi

WORK="$(mktemp -d "${TMPDIR:-/tmp}/restore-check.XXXXXX")"
chmod 700 "$WORK"
trap 'rm -rf -- "$WORK"' EXIT

if [[ ! -f "$CHECKSUM" ]]; then
  echo "ERROR: Checksum file not found: $CHECKSUM" >&2
  exit 1
fi

echo "Verifying SHA-256 checksum..."
(
  cd "$(dirname "$ARCHIVE")"
  sha256sum -c "$(basename "$CHECKSUM")"
)

echo "Checking decryption and archive readability..."
age -d "$ARCHIVE" | tar -tzf - > "$WORK/archive-list.txt"

echo "Checking archive paths..."
python3 - "$WORK/archive-list.txt" <<'PY'
import sys
from pathlib import PurePosixPath

listing = sys.argv[1]

with open(listing, "r", encoding="utf-8", errors="strict") as f:
    for line_number, line in enumerate(f, 1):
        name = line.rstrip("\n")

        if not name:
            continue

        path = PurePosixPath(name)

        if path.is_absolute() or ".." in path.parts:
            raise SystemExit(
                f"ERROR: Unsafe archive path at entry {line_number}: {name!r}"
            )

print("Basic path checks passed.")
PY

echo
echo "Archive entry count:"
wc -l < "$WORK/archive-list.txt"

echo
echo "First entries:"
head -n 20 "$WORK/archive-list.txt"

echo
echo "Components found for review:"
grep -E '(^|/)(config.yaml|auth.json|state.db|data.sqlite|hermes-gateway.service|9router-image.tar)$' \
  "$WORK/archive-list.txt" || true

echo
echo "Destination path is available."
echo "No destination directory was created."

echo
echo "Preflight completed."
echo "No files were extracted, no application data was restored,"
echo "and no services were started."
```
