# Hermes Agent + 9Router Restore Checklist

Use this checklist when restoring the deployment to a new VPS.

## 1. Before Restoration

- [ ] Keep the original VPS running.
- [ ] Confirm the encrypted backup exists outside the original VPS.
- [ ] Verify the SHA-256 checksum against a trusted copy.
- [ ] Confirm the backup passphrase is available.
- [ ] Confirm the target VPS has sufficient disk space and memory.
- [ ] Identify the target operating system and required dependencies.
- [ ] Create a separate backup of any existing target data.

## 2. Inspect the Backup

- [ ] Decrypt the archive in a protected environment.
- [ ] Verify the archive can be read completely.
- [ ] Inspect the directory structure before extraction.
- [ ] Confirm the expected Hermes Agent data is present.
- [ ] Confirm the 9Router persistent data is present.
- [ ] Confirm the Hermes Gateway service file is present.
- [ ] Confirm the 9Router Docker image archive is present.
- [ ] Check the SQLite snapshots for integrity.

## 3. Prepare the New VPS

- [ ] Install supported system dependencies.
- [ ] Install Docker and Docker Compose if required.
- [ ] Install a compatible Hermes Agent release.
- [ ] Verify the selected 9Router image and its requirements.
- [ ] Confirm that port 20128 is not unintentionally exposed publicly.
- [ ] Prepare protected directories for application data.

## 4. Restore Application Data

- [ ] Restore Hermes configuration and required application state.
- [ ] Restore the SQLite snapshots to their intended locations.
- [ ] Restore 9Router persistent data.
- [ ] Restore the Docker image if required.
- [ ] Restore the Gateway service configuration.
- [ ] Restore credentials securely from private storage.
- [ ] Check file ownership and permissions.
- [ ] Review configuration paths and API endpoints.

Do not overwrite destination data without a verified backup of the destination.

## 5. Validate 9Router

- [ ] Container starts successfully.
- [ ] Persistent data is present.
- [ ] Local API endpoint responds.
- [ ] Authentication works.
- [ ] Container logs contain no unresolved startup errors.
- [ ] Restart behavior has been tested.

## 6. Validate Hermes Agent

- [ ] Hermes Agent reports the expected version.
- [ ] Configuration references the intended 9Router endpoint.
- [ ] Provider authentication works.
- [ ] A test model request succeeds.
- [ ] The Gateway service starts successfully.
- [ ] Required memory and application state are available.
- [ ] Telegram integration responds if enabled.
- [ ] Required scheduled tasks and integrations are present.

## 7. Final Recovery Validation

- [ ] Application behavior is verified with representative tests.
- [ ] Services recover after a controlled restart.
- [ ] No credentials are exposed in public files or logs.
- [ ] A new encrypted backup has been created.
- [ ] A second recovery copy is stored outside the new VPS.
- [ ] The original VPS remains available until recovery is accepted.

## 8. Completion

Only consider the migration complete after all required checks have passed.

Keep the original VPS until the new environment is working and the recovery copies have been verified.

This checklist documents the intended process. It does not itself prove that a particular backup can be fully restored.
