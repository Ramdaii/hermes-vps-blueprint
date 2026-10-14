```bash
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

# Encrypted backup for Hermes Agent and 9Router.
# Does not stop services or modify source application data.
# Restore must be tested separately before relying on this backup.

BACKUP_DIR="${BACKUP_DIR:-/root/backup-hermes}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hermes-backup.XXXXXX")"

cleanup() {
  rm -rf -- "$WORK_DIR"
}
trap cleanup EXIT

for cmd in tar age sha256sum python3 cp find; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: Required command not found: $cmd" >&2
    exit 1
  }
done

HERMES_SRC="/root/.hermes"
ROUTER_SRC="/root/.9router"
SERVICE_SRC="/root/.config/systemd/user/hermes-gateway.service"
IMAGE_SRC="${BACKUP_DIR}/9router-image.tar"

[[ -d "$HERMES_SRC" ]] || {
  echo "ERROR: $HERMES_SRC not found" >&2
  exit 1
}

[[ -d "$ROUTER_SRC" ]] || {
  echo "ERROR: $ROUTER_SRC not found" >&2
  exit 1
}

STAGE="$WORK_DIR/staging"
mkdir -p "$STAGE/hermes" "$STAGE/9router" \
  "$STAGE/systemd" "$STAGE/docker"

mkdir -p -m 700 "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

echo "Copying application files to private staging..."
cp -a "$HERMES_SRC/." "$STAGE/hermes/"
cp -a "$ROUTER_SRC/." "$STAGE/9router/"

echo "Creating consistent SQLite snapshots..."

# Replace copied SQLite databases with snapshots made through SQLite's
# online backup API. Original application databases are not modified.
python3 - "$HERMES_SRC" "$ROUTER_SRC" "$STAGE" <<'PY'
import os
import sqlite3
import sys
from pathlib import Path

sources = [Path(sys.argv[1]), Path(sys.argv[2])]
stage = Path(sys.argv[3])

count = 0

for source_root in sources:
    for source in source_root.rglob("*"):
        if not source.is_file():
            continue

        # Cover the common SQLite extensions used by these applications.
        if source.suffix.lower() not in {".db", ".sqlite", ".sqlite3"}:
            continue

        relative = source.relative_to(source_root)
        if source_root == sources[0]:
            destination = stage / "hermes" / relative
        else:
            destination = stage / "9router" / relative

        destination.parent.mkdir(parents=True, exist_ok=True)
        temporary = destination.with_name(destination.name + ".snapshot")

        try:
            with sqlite3.connect(f"file:{source}?mode=ro", uri=True) as src:
                with sqlite3.connect(temporary) as dst:
                    src.backup(dst)
                    result = dst.execute("PRAGMA integrity_check").fetchone()
                    if not result or result[0] != "ok":
                        raise RuntimeError(
                            f"SQLite integrity check failed: {source}: {result}"
                        )

            os.replace(temporary, destination)
            count += 1
            print(f"Snapshot OK: {source}")

        except Exception:
            if temporary.exists():
                temporary.unlink()
            raise

print(f"SQLite snapshots completed: {count}")
PY

echo "Removing transient sockets and SQLite sidecars from staging..."
find "$STAGE" -type s -delete

# SQLite snapshots are standalone database files. Do not retain copied
# journal/WAL sidecars beside the replacement snapshots.
find "$STAGE/hermes" "$STAGE/9router" -type f \
  \( -name '*-wal' -o -name '*-shm' \) -delete

if [[ -f "$SERVICE_SRC" ]]; then
  cp -a "$SERVICE_SRC" "$STAGE/systemd/"
else
  echo "WARNING: Hermes Gateway systemd unit not found; skipping."
fi

if [[ -f "$IMAGE_SRC" ]]; then
  cp -a "$IMAGE_SRC" "$STAGE/docker/"
else
  echo "WARNING: 9Router Docker image archive not found; skipping."
fi

ARCHIVE="$BACKUP_DIR/hermes-vps-${TIMESTAMP}.tar.gz.age"
CHECKSUM="${ARCHIVE}.sha256"
PLAINTEXT="$WORK_DIR/backup.tar.gz"

echo "Creating archive..."
tar -C "$STAGE" -czf "$PLAINTEXT" .

echo "Encrypting archive..."
age -p -o "$ARCHIVE" "$PLAINTEXT"
chmod 600 "$ARCHIVE"

echo "Verifying encrypted archive can be decrypted and listed..."
age -d "$ARCHIVE" | tar -tzf - >/dev/null

echo "Creating SHA-256 checksum..."
(
  cd "$BACKUP_DIR"
  sha256sum "$(basename "$ARCHIVE")" > "$(basename "$CHECKSUM")"
)

chmod 600 "$CHECKSUM"

echo
echo "Backup archive created: $ARCHIVE"
echo "Checksum file created: $CHECKSUM"
echo
echo "IMPORTANT:"
echo "- Copy the encrypted archive and checksum off this VPS."
echo "- Store the passphrase separately."
echo "- Verify the checksum after transfer."
echo "- Test a complete restore on a separate VPS before migration."
echo "- This script does not guarantee a consistent snapshot of every"
echo "  non-SQLite file while services are running."
```
