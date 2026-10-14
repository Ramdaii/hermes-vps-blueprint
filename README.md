# Hermes VPS Blueprint

A reusable deployment and recovery blueprint for Hermes Agent and 9Router on Linux VPS environments.

## Project Goals

- Rebuild the environment when changing VPS providers.
- Document installation and recovery procedures.
- Keep public deployment scripts separate from private application data.
- Protect credentials, conversation history, and encrypted backups.
- Make recovery repeatable and verifiable.

## Components

- **Hermes Agent** — AI agent runtime and integrations.
- **9Router** — AI model routing through Docker.
- **Hermes Gateway** — managed through systemd.
- **Private backup** — encrypted application data and configuration.
- **GitHub repository** — public scripts, sanitized templates, and documentation.

## Repository Structure

```text
hermes-vps-blueprint/
├── README.md
├── .gitignore
├── 9router/
│   └── compose.yaml
├── scripts/
│   └── preflight.sh
└── docs/
    ├── installation.md
    └── backup.md
```

## Getting Started

1. Read `docs/installation.md`.
2. Review the target VPS operating system and resources.
3. Review `9router/compose.yaml` before using it.
4. Run the preflight checks on the target VPS.
5. Follow the installation procedure for compatible software versions.
6. Restore private configuration only from a verified backup.
7. Test the model connection, gateway, and integrations before production use.

## Backup and Recovery

Read `docs/backup.md` for the backup strategy, encryption requirements, integrity checks, and recovery checklist.

Private backups must be stored outside this public repository.

## Security

Never commit:

- API keys or provider credentials.
- Telegram bot tokens.
- Private authentication files.
- Conversation history, memory, or application databases.
- Backup archives or encryption passphrases.
- Unredacted configuration files.

The `.gitignore` file helps prevent accidental additions but is not a substitute for reviewing files before committing.

## Current Status

This repository is being built incrementally.

The documentation and scripts must be reviewed and tested against the selected software versions before being used for production recovery.

A successful backup decryption does not, by itself, prove that a complete application restore will succeed.

## Migration Policy

Keep the original VPS running until the replacement environment has been restored and validated.

Do not decommission the source server until the new deployment works and an independent recovery copy is available.
