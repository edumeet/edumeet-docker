# ![eduMEET](images/logo.edumeet.svg) full Docker deployment

<a name="edumeet-in-docker-container"></a>

This repository runs [eduMEET](https://github.com/edumeet/edumeet) with a
management server and optional login. For a smaller setup without management
or login, use the [minimal deployment](https://github.com/edumeet/edumeet#installation).
Images are published on [Docker Hub](https://hub.docker.com/u/edumeet).

## Getting started

- <a name="guides-click-to-open"></a><a name="recommended-configuration-of-vm--server"></a>
  <a name="general-architecture"></a><a name="install-dependencies"></a>
  <a name="configs"></a><a name="running-the-services"></a>
  [Install and start](docs/installation.md) — prerequisites, configuration and architecture
- [Networking](docs/networking.md) — firewall ports, addresses and NAT
- <a name="certificates"></a><a name="https-only-hsts"></a>
  [Certificates](docs/certificates.md) — Let's Encrypt, local HTTPS and HSTS
- <a name="configure-authentication"></a><a name="initial-setup-after-first-run"></a>
  <a name="auth"></a><a name="login-throttle"></a>
  [Authentication](docs/authentication.md) — managed rooms, OIDC and proxy settings
- <a name="logs"></a><a name="uninstall"></a><a name="backuprestore"></a>
  <a name="database-backup"></a><a name="database-restore"></a>
  [Operations](docs/operations.md) — logs, backups, troubleshooting and uninstall
- <a name="calendar-invites"></a><a name="prerequisites"></a><a name="fresh-install"></a>
  <a name="existing-install"></a><a name="optional-invite-settings"></a>
  <a name="per-tenant-configuration-via-management-ui"></a><a name="imap-is-optional"></a>
  <a name="landing-page"></a><a name="meetings-only-rooms"></a>
  [Meetings and calendar invitations](docs/meetings.md)
- <a name="development"></a><a name="dev"></a><a name="database-debug"></a>
  <a name="to-check-the-database"></a>[Development with Docker](docs/development.md)
- [Documentation maintenance](https://github.com/edumeet/edumeet#documentation)
- <a name="changelog"></a>[Changelog](https://github.com/edumeet/edumeet/blob/main/CHANGELOG.md)

## Firewall ports and recommendations
See [networking](docs/networking.md) for the public and restricted ports,
addresses and NAT configuration.

![Overview of eduMEET Docker network paths](images/edumeet-network-overview.svg)

