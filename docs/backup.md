# Backup and Recovery Guide

This document describes the backup strategy for Hermes Agent and 9Router.

## 1. Backup Principles

- Keep the original VPS running until recovery is verified.
- Keep private backups separate from the public GitHub repository.
- Encrypt backups containing credentials or private application data.
- Verify backup integrity before relying on it.
- Keep the backup passphrase separate from the encrypted archive.
- Maintain at least one verified backup copy outside the source VPS.

## 2. Components to Preserve

The backup plan should account for:

- Hermes Agent configuration and authentication.
- Hermes databases, memory, sessions, and application state.
- Hermes Gateway systemd service configuration.
- 9Router persistent data and configuration.
- The 9Router Docker image or a reproducible image reference.
- Software versions and installation documentation.

Inspect the actual installation before deciding which files are required.

## 3. Database Backups

Hermes Agent and 9Router may use SQLite databases.

Use SQLite's supported backup mechanism for active databases instead of copying database files blindly.

After creating a snapshot, run an integrity check on the copied database.

A successful SQLite integrity check is useful evidence, but it does not prove that every application feature can be restored.

## 4. Encrypt Private Backups

Use an established encryption tool such as `age` to encrypt the backup archive.

Requirements:

1. Use a strong, unique passphrase.
2. Store the passphrase in a password manager or another secure location outside the VPS.
3. Do not place the passphrase in shell scripts, Git history, or public documentation.
4. Do not upload private archives or credentials to this repository.
5. Keep an independent recovery copy of the encrypted archive.

If the passphrase is lost, the encrypted archive may be unrecoverable.

## 5. Verify the Archive

Before moving a backup:

1. Confirm that the archive file exists and is non-empty.
2. Test decryption using the correct passphrase.
3. Test archive readability.
4. Confirm that required configuration, databases, and application files are included.
5. Generate a SHA-256 checksum.

Example:

`sha256sum backup.tar.gz.age`

Store the checksum separately from the archive when practical.

After transferring the archive to another machine, calculate its SHA-256 checksum again and compare the result with the original.

## 6. Store Backups Outside the Source VPS

Do not rely on a backup stored only on the VPS being migrated.

Keep a verified encrypted copy on a separate device or private storage service.

The public GitHub repository is for installer scripts, documentation, and sanitized configuration templates, not private backups.

## 7. Recovery Procedure

1. Prepare a compatible Linux VPS.
2. Install the required system dependencies.
3. Transfer the encrypted backup securely.
4. Verify the checksum.
5. Decrypt the archive in a protected directory.
6. Inspect the archive contents before extraction.
7. Restore databases and application files to their intended locations.
8. Restore credentials securely.
9. Review ownership, permissions, and configuration paths.
10. Start services using the documented procedure.
11. Validate API connectivity, model responses, gateway operation, and integrations.

Avoid overwriting existing data until a separate backup of the destination has been created.

## 8. Recovery Testing

A backup should not be considered fully validated solely because its archive can be decrypted.

Test recovery in a separate environment and verify:

- Databases can be opened and pass integrity checks.
- Hermes Agent starts successfully.
- 9Router starts with the expected persistent data.
- Hermes can authenticate with the configured provider.
- The gateway remains active.
- Required memory and integrations are available.

## 9. Source VPS Decommissioning

Do not cancel or delete the original VPS until:

- The encrypted backup exists outside the source VPS.
- The checksum has been verified after transfer.
- Recovery has been tested on the replacement VPS.
- Required services and integrations work.
- A separate recovery copy is available.

## 10. Current Backup Status

Document the backup date, software versions, archive location, checksum, and recovery test results separately.

Never record the backup passphrase or API credentials in this document.
