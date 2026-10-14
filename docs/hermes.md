# Hermes Agent Configuration and Recovery

## 1. Existing Deployment

The current Hostinger environment has the following characteristics:

- Hermes Agent version: `v0.21.5+7531.g665a42bb`
- Installation method: Git
- Installation directory: `/root/.hermes/hermes-agent`
- Python runtime: `3.14.7`
- Gateway service: `hermes-gateway.service`
- Gateway service manager: systemd user service
- Main data directory: `/root/.hermes`

The existing deployment inventory reported that the gateway service was active.

## 2. Connection to 9Router

The configured API endpoint is:

`http://127.0.0.1:20128/v1`

The existing model configuration uses a custom provider and a model alias.

The actual provider configuration, model identifier, API key, and authentication details must be restored privately. Do not place their original values in this repository.

## 3. Data to Preserve

The private backup should account for the contents of `/root/.hermes`, including:

- Configuration and authentication files.
- SQLite databases.
- Conversation and session data.
- Memory and application state.
- Project and task data.
- Cron configuration and execution history.
- Profiles and related application files.
- Gateway service configuration.

Inspect the actual archive before restoration. Not every file is necessarily required for every deployment, and some runtime files may need to be recreated rather than restored.

## 4. Installation

Before installing Hermes Agent on a new VPS:

1. Confirm the supported operating system and Python requirements.
2. Review the official installation instructions for the intended release.
3. Install a compatible Hermes Agent version.
4. Restore required private configuration and application data.
5. Check file ownership and permissions.
6. Configure the connection to the local 9Router endpoint.
7. Configure the gateway using the supported service installation procedure.

Do not assume that copying the service unit alone is sufficient to recreate a working systemd user service.

## 5. Gateway Validation

After restoration, verify:

- The gateway service starts successfully.
- The service remains active.
- Hermes can connect to the configured model provider.
- A test model request succeeds.
- Required integrations respond correctly.
- The service can recover after a controlled restart.

Useful diagnostic commands include:

`hermes --version`

`hermes config get model`

`systemctl --user status hermes-gateway.service --no-pager`

Review command output before sharing it publicly. Configuration output and logs may contain sensitive information.

## 6. Security

Never commit the following to this repository:

- `auth.json`
- API keys or provider credentials.
- Telegram bot tokens.
- Private configuration files.
- Databases, conversation history, or memory data.
- Unredacted logs or request dumps.
- Backup archives or encryption passphrases.

Store private application data in a separate encrypted backup.

## 7. Recovery Checklist

- [ ] Correct Hermes Agent version is installed.
- [ ] Required private data is restored.
- [ ] Configuration points to the intended 9Router endpoint.
- [ ] Provider authentication works.
- [ ] Test model request succeeds.
- [ ] Gateway service remains active.
- [ ] Required memory and application state are available.
- [ ] Integrations have been tested.
- [ ] Recovery copy is retained outside the VPS.

## 8. Recovery Status

This document records the existing deployment inventory and intended recovery procedure. The full restore procedure has not yet been tested on a replacement VPS.
