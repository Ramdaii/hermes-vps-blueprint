# 9Router Configuration and Recovery

## 1. Existing Deployment

The current Hostinger deployment uses:

- Docker image: `decolua/9router:latest`
- Container name: `9router`
- Host port: `20128`
- Host binding: `127.0.0.1`
- Persistent data directory: `/root/.9router`
- Container data directory in the current Compose template: `/app/data`

These values are based on the existing deployment inventory. The complete restoration procedure has not yet been validated.

## 2. Network Configuration

The intended local API endpoint is:

`http://127.0.0.1:20128/v1`

The port should remain bound to localhost by default. Do not expose the API directly to the public internet.

## 3. Persistent Data

The `/root/.9router` directory contains application data that must be preserved during migration.

Before restoring:

1. Verify the encrypted backup.
2. Create a backup of any existing destination data.
3. Inspect the archive contents.
4. Restore data to the correct application directory.
5. Check file permissions and ownership.
6. Start the container and inspect its logs.

Never overwrite the source VPS data as part of the migration.

## 4. Image and Configuration Validation

Before production use, verify:

- The exact image version and digest.
- Required environment variables and startup options.
- The actual persistent data path inside the container.
- Authentication requirements.
- Database migration or initialization behavior.
- API connectivity from Hermes Agent.

Do not assume that the `latest` image tag will always refer to the same version.

## 5. Security

- Keep API credentials outside the public repository.
- Do not commit `.env` files containing secrets.
- Do not publish private databases or configuration files.
- Keep the API bound to localhost unless a reviewed alternative is required.
- Store encrypted backups separately from the source VPS.

## 6. Validation Checklist

- [ ] Container starts successfully.
- [ ] Persistent data is present.
- [ ] API responds on localhost.
- [ ] Authentication works.
- [ ] Hermes Agent can connect to the API.
- [ ] A test model request succeeds.
- [ ] Container restart behavior is verified.

## 7. Recovery Status

This document describes the existing deployment and intended recovery requirements. The Compose template and restoration procedure must be tested on a separate VPS before production migration.
