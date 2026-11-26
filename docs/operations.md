# Full Docker deployment: operations

Run these commands from the `edumeet-docker` directory.

## Status and logs

```bash
docker compose ps
docker compose logs
docker compose logs -f edumeet-room-server
```

Set `SERVER_DEBUG_LEVEL=debug` in `.env` for room-server application logs, or
`LOG_LEVEL=debug` for media-node and management-server application logs. Apply
the change with `docker compose up -d`. Library `*_DEBUG` variables are not a
substitute for these application log levels.

## Files with secrets

Keys and passwords are in several files of the installation, not only in `.env`:

- `.env`: the admin passwords, the media secret, the signing key.
- `configs/mgmt/default.json`: the key that signs every login, the keys for
  invitations, the database password. Whoever reads it can sign in as anyone.
- `certs/` and `certbot/`: the TLS keys.

`utils/run-me-first.sh` therefore closes the whole installation directory to the
other accounts of the host (`chmod go-rwx .`). The containers are not affected:
each gets its files mounted and reads them as before. Do not open the directory
again; give a second administrator access through `sudo` or a shared account.
A copy or backup of the directory needs the same care.

**Upgrading from `4.2-20261126-stable` or older:** the setup script used to write
the admin password into `configs/_mgmt_pwchange/202310300000000_migrate.ts`, and
it left the directory open. Put that file back before you pull, and close the
directory:

```bash
git checkout configs/_mgmt_pwchange/202310300000000_migrate.ts
git pull
chmod go-rwx .
```

Without the first command `git pull` stops, because the file was changed
locally. The new file reads the password from the environment and contains no
secret. If other people have accounts on the host, treat the admin password and
the signing key as known to them: set a new password (below), create a new key
by running `utils/run-me-first.sh` again, and restart with `docker compose up -d`.
Everyone who is signed in then has to sign in again.

### Admin password

When the database is created, the management server gives its first user the
address and password of `MANAGEMENT_USERNAME` and `MANAGEMENT_PASSWORD` in
`.env`. The room server signs in with the same two values. To change the
password later:

```bash
docker compose exec -it edumeet-management-server yarn set-password <address>
```

Then write the new password to `MANAGEMENT_PASSWORD` in `.env` and run
`docker compose up -d` so that the room server uses it.

## Backup and restore

Back up the database **and** the configuration and secrets needed to use it:
`.env`, `configs/`, `certs/` and `certbot/conf/`. Store backups securely. In
particular, the invite encryption key is needed to decrypt saved SMTP/IMAP
credentials. Back up identity-provider data separately; this database dump
does not include it.

The bundled Keycloak service uses an H2 database in its container. The Compose
configuration now mounts this data at `/opt/keycloak/data` in the
`keycloak-data` volume, so it survives container replacement. The separate
`edumeet-db` PostgreSQL service is for the management server, not Keycloak.
The Compose service also applies a temporary workaround for CVE-2026-114938 by
disabling the JDK's AVX-512 Base64 optimization in Keycloak. Any
`JAVA_OPTS_APPEND` value in `.env` is preserved. Keep this workaround until the
Keycloak image includes a fixed JDK.
This persistence does not make the bundled Keycloak production-ready; see the
[production warning](authentication.md#production-warning).

**One-time migration when upgrading from `4.2-20261113-stable` or older:**
before the first `docker compose up -d` after pulling the updated Compose file,
copy the existing Keycloak data into the new volume. Otherwise, recreating the
container starts with an empty volume and the old realms, clients and local
users are lost. Run these commands from the deployment directory:

```bash
docker compose stop keycloak
docker cp -a edumeet-keycloak:/opt/keycloak/data ./keycloak-data-backup
docker compose create keycloak
docker cp -a ./keycloak-data-backup/. edumeet-keycloak:/opt/keycloak/data/
docker compose up -d
```

Check that your realm is present before deleting `keycloak-data-backup`.
Skip this migration if Keycloak uses an external database (`KC_DB` is set in
`.env`). Back up Keycloak data separately from the management database dump.

### Database backup

For the default PostgreSQL user and database, create a custom-format dump:

```bash
docker compose exec -T edumeet-db pg_dump -U edumeet -Fc edumeet > edumeet.dump
```

Check that the command succeeds; a failed command can leave an incomplete
file. If you changed the database user or name, use your configured values.
This dump covers the `edumeet` database, not PostgreSQL roles, other databases
or identity-provider data. Older backups made with the README's `pg_dumpall`
command are plain SQL, not custom-format dumps, and need a different restore
procedure.

### Test a database backup

On a **separate test instance**, with a fresh database and the backup file
available, restore it using:

```bash
docker compose exec -T edumeet-db createdb -U edumeet edumeet_restore_check
docker compose exec -T edumeet-db pg_restore --exit-on-error --no-owner --no-acl \
  -U edumeet -d edumeet_restore_check < edumeet.dump
```

Inspect the restored data and test the application before relying on a backup.
The test restore uses the test user as owner and does not restore access
privileges. A production recovery needs a plan for roles, permissions,
configuration and any identity provider; it can overwrite data and has not
been verified by this test. Do not run these commands against production.

## Troubleshooting

| Symptom | Start by checking |
| --- | --- |
| Website unavailable | DNS, proxy status and logs, and ports 80/443 in [networking](networking.md). |
| Certificate errors | Both domain names, the proxy certificate and the [certificate guide](certificates.md). |
| Browser shows a certificate error without a way to continue, or changes `http://` to `https://` for another service on the same host name | The proxy sends an HSTS header; see [HTTPS only (HSTS)](certificates.md#https-only-hsts). |
| Page loads but media fails | The announced public IP, media ranges, NAT forwarding and media-node logs. |
| Login fails | Tenant FQDN, identity-provider configuration and [authentication](authentication.md). |

## Stop or uninstall

`docker compose down` stops and removes this project's containers and networks.
`docker compose down --volumes` also deletes its volumes, including the
management database and Keycloak's realms and users. Use it only after backing
up anything you need. Docker-wide prune commands can remove unused resources
from other projects.
