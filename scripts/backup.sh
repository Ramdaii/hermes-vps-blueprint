
#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

# Create an encrypted backup of Hermes Agent and 9Router.
# This script does not stop or modify running services.
# Review archive contents before relying on a backup.

BACKUP_DIR="${BACKUP_DIR:-/root/backup-hermes}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hermes-backup.XXXXXX")"

cleanup() {
  rm -rf -- "$WORK_DIR"
}
trap cleanup EXIT

for cmd in tar age sha256sum python3; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "ERROR: Required command not found: $cmd" >&2
    exit 1
  }
done

[[ -d /root/.hermes ]] || {
  echo "ERROR: /root/.hermes not found" >&2
  exit 1
}

[[ -d /root/.9router ]] || {
  echo "ERROR: /root/.9router not found" >&2
  exit 1
}

mkdir -p -m 700 "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

ARCHIVE="$BACKUP_DIR/hermes-vps-${TIMESTAMP}.tar.gz.age"
CHECKSUM="${ARCHIVE}.sha256"

echo "Creating private staging copy..."

mkdir -p "$WORK_DIR/data/hermes" "$WORK_DIR/data/9router"

# Copy data without stopping services. Live files can change during copying.
# SQLite databases should be snapshotted using SQLite's backup API.
cp -a /root/.hermes/. "$WORK_DIR/data/hermes/"
cp -a /root/.9router/. "$WORK_DIR/data/9router/"

# Remove transient Unix sockets from the staging copy.
find "$WORK_DIR/data" -type s -delete

echo "Creating archive..."

tar -C "$WORK_DIR/data" -czf "$WORK_DIR/backup.tar.gz" .

echo "Encrypting archive..."
echo "Enter your age passphrase when prompted."

age -p -o "$ARCHIVE" "$WORK_DIR/backup.tar.gz"

chmod 600 "$ARCHIVE"

(
  cd "$BACKUP_DIR"
  sha256sum "$(basename "$ARCHIVE")" > "$(basename "$CHECKSUM")"
)

chmod 600 "$CHECKSUM"

echo
echo "Backup archive created:"
echo "$ARCHIVE"
echo
echo "Checksum file created:"
echo "$CHECKSUM"
echo
echo "IMPORTANT:"
echo "- Copy the encrypted archive outside this VPS."
echo "- Store the passphrase separately."
echo "- Verify database snapshots and archive contents."
echo "- This script does not guarantee a consistent live database backup."
