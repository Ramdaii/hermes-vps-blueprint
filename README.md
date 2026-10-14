# Hermes VPS Blueprint

A reproducible setup for deploying and restoring Hermes Agent and 9Router on a Linux VPS.

## Goals

- Document the installation of Hermes Agent and 9Router.
- Keep deployment scripts and configuration templates version-controlled.
- Separate public installation files from private credentials and backups.
- Provide a repeatable recovery process when moving between VPS providers.

## Components

- Hermes Agent
- 9Router using Docker
- Hermes Gateway managed by systemd
- Configuration templates and recovery documentation

## Repository Structure

```text
hermes-vps-blueprint/
├── README.md
├── .gitignore
├── install/
├── hermes/
├── 9router/
├── scripts/
└── docs/
```

## Security

**Never commit secrets or private backups to this repository.**

Do not upload:

- API keys or provider credentials
- Telegram bot tokens
- `.env` files containing secrets
- Authentication files such as `auth.json`
- Private databases, conversation histories, or memory files
- Encrypted backup archives or backup passphrases

Use environment variables or another secure secret-management method for credentials.

## Recovery Overview

1. Prepare a supported Linux VPS.
2. Install the required system dependencies.
3. Deploy 9Router and configure its persistent storage.
4. Install Hermes Agent and configure its gateway.
5. Restore private configuration and data from an independently stored backup.
6. Validate the AI provider, Telegram integration, and gateway service.

Detailed installation and recovery instructions will be added as the scripts are validated.

## Important

This repository is a deployment blueprint. A successful Git clone alone does not restore private data, credentials, conversation history, or provider access.
