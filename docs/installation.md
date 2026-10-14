# Installation Guide — Hermes Agent + 9Router

This guide documents the planned installation of Hermes Agent and 9Router on a new Linux VPS.

The deployment must be validated on a test server before replacing an existing production server.

## 1. Architecture

The intended setup consists of:

- Hermes Agent for agent execution and integrations.
- 9Router running in Docker.
- Hermes Gateway managed by systemd.
- A local API connection from Hermes to 9Router.
- Private persistent storage for configuration, authentication, databases, memory, and sessions.

Expected local API endpoint:

`http://127.0.0.1:20128/v1`

The API must not be exposed publicly unless a separately reviewed security configuration requires it.

## 2. Prerequisites

Before installation, confirm:

- A fresh Linux VPS with a supported operating system.
- SSH access with administrative privileges.
- Sufficient CPU, RAM, and disk space.
- A working internet connection.
- Docker Engine and Docker Compose support, where required.
- Secure storage for API keys, provider credentials, and Telegram bot tokens.
- Access to the encrypted backup and its passphrase if restoring an existing deployment.

Do not assume that every operating system or software version is compatible. Verify the current installation instructions for each component before proceeding.

## 3. Prepare the VPS

Connect to the new server through SSH.

Run the read-only preflight script to inspect the operating system, CPU, memory, disk space, Docker availability, and port 20128.

Review the output before installing packages or changing system configuration.

Do not run installation or restore scripts as root unless their behavior has been reviewed.

## 4. Install 9Router

1. Review the official installation instructions for the selected 9Router release.
2. Install Docker if required.
3. Select and verify the intended 9Router image version.
4. Configure persistent storage for `/app/data`.
5. Bind API port 20128 to `127.0.0.1` by default.
6. Configure authentication and other required environment variables using the documented mechanism.
7. Start the container only after reviewing the configuration.

Verify the container status and review its logs for startup errors.

Do not expose the API directly to the public internet.

## 5. Install Hermes Agent

1. Review the official Hermes Agent installation instructions.
2. Install a compatible release.
3. Configure the intended AI provider and model.
4. Configure the API base URL as `http://127.0.0.1:20128/v1` when using the local 9Router service.
5. Configure authentication without committing credentials to Git.
6. Configure the Hermes Gateway service using the supported systemd instructions.

The provider name, model identifier, API mode, and authentication requirements must match the selected 9Router configuration.

## 6. Restore an Existing Deployment

Restore only from a verified private backup.

1. Transfer the encrypted backup to the new VPS using a secure method.
2. Verify its SHA-256 checksum against a separately stored trusted value.
3. Decrypt it using the locally stored passphrase.
4. Inspect the archive contents before extraction.
5. Restore files and databases to their intended locations.
6. Restore private credentials securely.
7. Review file ownership and permissions.
8. Start the services using the documented startup procedure.

Do not overwrite active configuration or databases without first creating a separate backup of the destination.

## 7. Validation Checklist

Before switching production traffic, verify:

- [ ] 9Router starts successfully.
- [ ] The API is accessible locally.
- [ ] API authentication works.
- [ ] Hermes can connect to 9Router.
- [ ] The selected AI model completes a test request.
- [ ] Hermes Gateway starts and remains active.
- [ ] Telegram integration responds correctly, if enabled.
- [ ] Required memory, sessions, and application data are present.
- [ ] Services recover after a controlled restart test.
- [ ] No secrets are exposed in public files or logs.

## 8. Security Requirements

Never commit the following to this repository:

- API keys or provider credentials.
- Telegram bot tokens.
- Private authentication files.
- Database files or conversation histories.
- Unencrypted backups.
- Backup passphrases or private encryption keys.

Use a separate encrypted backup location for private data.

## 9. Production Cutover

Keep the original VPS running until the new deployment has passed all validation checks.

Switch production integrations only after confirming that the new deployment works.

Retain the original VPS and its backup until the new environment is verified and a separate recovery copy is available.

## 10. Current Status

This document describes the planned deployment and recovery procedure. Commands, software versions, configuration requirements, and restore steps must be validated against the selected releases before production use.
