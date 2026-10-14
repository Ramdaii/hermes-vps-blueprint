# 9Router Configuration

## Current Deployment Reference

The existing deployment uses the following configuration:

- Docker image: `decolua/9router:latest`
- Container name: `9router`
- API port: `20128`
- Host binding: `127.0.0.1`
- Persistent data directory: `/root/.9router`
- Container data directory: `/app/data`

## Network Security

The API is bound to localhost by default:

`127.0.0.1:20128`

This prevents direct access through the VPS public network interface.

For remote administration, use an authenticated and encrypted access method rather than exposing the API port publicly.

## Persistent Data

The existing deployment stores persistent data in `/root/.9router`.

Before restoring on another VPS:

1. Stop the destination container if it is already running.
2. Back up any existing destination data.
3. Restore the verified private backup to the intended directory.
4. Check ownership and permissions.
5. Start the container and validate its operation.

Do not overwrite the source VPS data during migration.

## Configuration Validation

Before using the public Compose template in production, verify:

- Required environment variables.
- Authentication settings.
- Persistent data requirements.
- Compatibility of the selected Docker image.
- API connectivity from Hermes Agent.
- Container startup and restart behavior.

The Compose file in this repository is a deployment template based on the existing container's visible configuration. It has not yet been validated as a complete restoration procedure.
