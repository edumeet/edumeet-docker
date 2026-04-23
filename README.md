# ![eduMEET](/images/logo.edumeet.svg) in Docker container

This is "dockerized" version of the [eduMEET](https://github.com/edumeet/edumeet). 
(Successor of [multiparty meeting](https://github.com/havfo/multiparty-meeting) fork of mediasoup-demo)

Docker hub repository: [edumeet](https://hub.docker.com/u/edumeet)

It will setup a production eduMEET instance with or without authentication, and help you with setting up a development environment.

For further (more generic) information take a look at [eduMEET repository](https://github.com/edumeet/edumeet)
_________________

- Current stable eduMEET consists of these components:
  - [edumeet-client](https://github.com/edumeet/edumeet-client/)
  - [edumeet-room-server](https://github.com/edumeet/edumeet-room-server)
  - [edumeet-media-node](https://github.com/edumeet/edumeet-media-node)
  - [edumeet-management-server](https://github.com/edumeet/edumeet-management-server)

Releases are docker images with the 'stable' tag ending:
| Component    | Docker images |
| -------- | ------- |
| edumeet-client  | ![Docker Image for client (latest)](https://img.shields.io/docker/v/edumeet/edumeet-client)   |
| edumeet-room-server | ![Docker Image for room-server (latest)](https://img.shields.io/docker/v/edumeet/edumeet-room-server)     |
| edumeet-media-node    | ![Docker Image for room-server (latest)](https://img.shields.io/docker/v/edumeet/edumeet-media-node)    |
| edumeet-management-server    | ![Docker Image for room-server (latest)](https://img.shields.io/docker/v/edumeet/edumeet-management-server)    |


# Getting started
## Guides (click to open):
<details>
  <summary>Recommended configuration + introduction</summary>
  
### Recommended configuration of VM / server:
|   | Specs | 
| ---- | ----------- |
|  CPU | typical modern CPU (8 cores) | 
|  RAM | 8 GB | 
|  HDD | 100GB | 
|  network | 1 network adapter (1Gb/s) | 
| OS | Ubuntu / Debian | 
|| public IP address (without any NAT) |
|| 2 FQDN name assigned (for certificates) |

In edumeet-docker components are linked together via the proxy (nginx) docker image.

By default it is using the docker networking hostnames to connect/link components.

Since some components need the hostname / domain name / IP to function it is included in every config and can be changed depending on the use case.

It also makes certificate renewal easy since on a single domain setup you only need to change the cert in the certs folder.

eduMEET client is the frontend, room-server is the backend, management-server is the auth backend, media-node is used for everything media related.

 # ![General Architecture](/images/edumeet_general_component_functions.png)

</details>

## Install dependencies
```bash
sudo apt install jq ack
```
Install docker compose V2: https://docs.docker.com/engine/install/debian/#install-using-the-repository

Optional (add current user to docker group )
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

Download repo:

```bash
git clone https://github.com/edumeet/edumeet-docker.git
cd edumeet-docker
```

## Changelog
For latest changes and releases see: 
https://github.com/edumeet/edumeet/blob/main/CHANGELOG.md

## Firewall ports and recommendations
| Port | protocol | description | network | path | firewall advice | 
| ---- | ----------- | ----------- | ----------- | ----------- |--------------|
|  80 | tcp | edumeet-client webserver (redirect to 443) | host network | / | |
|  443 | tcp | edumeet-client https webserver and signaling proxy | host network |  / | |
|  3000 |  | edumeet-media-node port | host network | - | should be limited so only the room-server can access it |
|  3479 |  | coturn port | host network | - | |
|  40000-40249 | tcp/udp | edumeet-media-node ports | host network | - | |

 # ![Network](/images/edumeet_netw.png)


## Configs

Configure:
```
./utils/run-me-first.sh
```
You can do this manually  as well. Changes need to be done in the .env file, and in the config directory.

This will create the initial setup, so the service can start, the authentication has to be configured in 2 components. 

In this setup you will have :
- Your management service UI avaliable at: yourdomain/mgmt-admin
- Your keycloak instance running at yourdomain/kc/

We currently only support OIDC authentication.
We include keycloak to have the ablility to administer local users in case you do not already have any OIDC provider application.

## Certificates

Generate certs (for development): 
```
./utils/gen_dev_cert.sh
```

Generate certs (with Let’s Encrypt): 
```
./utils/gen_cert.sh
```
You can add your prod certs into the certs directory manually, but then you need to modify the nginx config as well.
## Running the services
Start services:
```
docker compose up -d
```
Check running services
```
docker ps
```
Stop services
```
docker compose down
```

## Configure authentication

### Initial setup after first run

Authentication is optional but if you want to enable it, you should remove defualtroom paremeters from the config.json at configs/server/ and follow these steps.

For auth you can use any OpenID compatible backend. Keycloak is reccomended for testing, integrating with common third party auth sources and deployments without a central authentication (local users).

For federated login with discovery we reccommend using SATOSA.

1. visit https://yourdomain.com/kc/ and set up your keycloak instance
configuration according to https://github.com/edumeet/edumeet-management-server/wiki/Keycloak-setup-(OAuth-openid-connect)

At this step you can create a test user for example:
- Username: edumeet
- Password: edumeet

2. visit https://yourdomain.com/mgmt-admin/ and set up your management server config
   - Create a tenant
   - Create a tenant fqdn / domain
   - Add authentication by using the Well Known URL "https://yourdomain.com/kc/realms/ < yourrealm > /.well-known/openid-configuration" and pressing "Update Parameters from URL" or manually as follows: 
 # ![auth](/images/mgmt-client-setup-1.png)

   * Secret is located in keycloak admin console/ < yourrealm > / clients / < yourclient > / credentials
   *  Key is < yourclient >

    
3. Logout 
4. Visit your domain/fqdn that has been configured (Login with your test user)
5. Visit https://yourdomain.com/mgmt-admin/ and as the logged in user create a room ( You will be assigned as a room owner and gain all permissions after login, but you can also set permissions for other users too. )
6. Join the room



## Calendar invites

edumeet can send ICS calendar invites (RFC 5545 / RFC 6047 iTIP) for meetings scheduled in existing rooms. Attendees receive the invite in Gmail/Outlook/Apple Calendar, RSVP natively from their mail client, and the response flows back into edumeet via IMAP. Recurring meetings are supported.

### Prerequisites

Each tenant that wants to send invites needs a **dedicated SMTP mailbox on their domain** (e.g. `invites@tenantA.com`). The same mailbox is used to send invites *and* (optionally) receive RSVP replies via IMAP, so it must not be a human inbox — the poller marks processed messages as seen and ignores non-iTIP mail.

For best deliverability, ensure the mailbox's domain has valid **SPF and DKIM** records. Without them, invites will land in spam.

### Fresh install

`./utils/run-me-first.sh` already generates the two required secrets (`invites.encryptionKey` for AES-256-GCM encryption of stored SMTP/IMAP passwords, and `invites.rsvpTokenSecret` for HMAC-SHA256 RSVP tokens) and writes them into `configs/mgmt/default.json`. Nothing extra to do at deploy time.

### Existing install

Run:
```
./utils/gen-invite-secrets.sh
```
This prints an `"invites": { ... }` JSON block. Paste it at the top level of `configs/mgmt/default.json` (next to the existing `"authentication"` block) and restart the management server:
```
docker compose restart edumeet-management-server
```

> **Do not rotate these secrets** after tenants have configured invite credentials. The `encryptionKey` is required to decrypt previously stored SMTP/IMAP passwords. Rotation would invalidate every stored tenant invite config.

### Per-tenant configuration (via management UI)

1. Log in to `https://yourdomain.com/mgmt-admin/` as a tenant admin or tenant owner.
2. Go to **Tenants**, click the tenant row to open the edit dialog.
3. Expand the **Invite email (SMTP/IMAP)** accordion.
4. Fill in the organizer address (the From: line, e.g. `invites@tenantA.com`), organizer display name, SMTP block (host, port, TLS, user, password) and optionally IMAP block.
5. Apply.

Invite workers boot automatically for that tenant — no restart needed.

### IMAP is optional

If IMAP is left blank, invites still work: attendees receive the ICS and can RSVP from their calendar client. The only thing missing is per-attendee RSVP status surfaced in the edumeet admin UI. Within the same provider (Google↔Google, Outlook↔Outlook) attendees still see each other's status natively. Tenants on Gmail/M365 that can't provide basic-auth IMAP can skip it.

> **RSVPs from Thunderbird + Google Calendar are unreliable.** When Thunderbird's calendar event comes from a Google Calendar (via CalDAV / Provider for Google), accepting or declining the invite in Thunderbird writes the new response to Google via CalDAV but does **not** send an iMIP REPLY email. Because Google is not the meeting organizer in this setup, Google will not proxy an RSVP email either. The change is invisible to edumeet and the attendee stays as NEEDS-ACTION in the admin UI. For a reliable RSVP, respond on [calendar.google.com](https://calendar.google.com) directly — that path does send an iMIP REPLY.

### Landing page

Logged-in users see a calendar icon button next to the login/logout button in the landing, join, and lobby dialogs. The button is only visible when the user's tenant has invites enabled. Clicking opens a dialog listing upcoming meetings (both organized by and invited to the user) with inline Join buttons, a refresh button, and a shortcut to the full management page.

## Logs
To see logs (add -f for tailing the logs):
```
docker compose logs
```

To see logs of a component:
```
docker logs -f <component>
```

In the .env file there are a few log variables:

SERVER_DEBUG=

MGMT_DEBUG=

MGMT_CLIENT_DEBUG=

MN_DEBUG=

Changing them to * will provide extended logs that can help  debugging problems.

## Uninstall
Remove unused images (After stopping services):
```
docker system prune -a
```
Remove unused volumes/database data
```
docker volume prune -a
```

## Backup/restore
### Database backup:
```
docker compose exec edumeet-db pg_dumpall -U edumeet > pgdump.sql
```
### Database restore:
Drop previous tables  (This will delete data make sure you have a backup!)
```
docker exec -i  edumeet-db psql -U edumeet -d edumeet -c "DO \$\$ DECLARE r RECORD; BEGIN FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(r.tablename) || ' CASCADE'; END LOOP; END \$\$;"
```
Load data back
```
cat pgdump.sql | docker exec -i  edumeet-db psql -U edumeet -d edumeet
```

## Development

Build your own branches:
```
docker compose build --no-cache
```

For individual components:
```
docker compose build --no-cache <component name>
```


eduMEET development usualy happens in 2 ways:
- Running components manualy
- Running edumeet-docker with components linked into the docker container or passed to the proxy.

*Without valid certs you have to allow localhost/local ip to work without certs in the browser. Once for the website, once more for the socket.io connection (replace wss:// with https:// and accept there as well).

# ![Dev](/images/edumeet_dev.png)

## Database debug

### To check the database:
Get into the container:
```
docker exec -it edumeet-db bash
```
Go into postgres account:
```
354337e15cfa:/# su postgres
```
Connect to database:
```
$ psql -U edumeet
psql (18.0)
Type "help" for help.

edumeet=# \dt
                 List of tables
 Schema |         Name         | Type  |  Owner  
--------+----------------------+-------+---------
 public | groupUsers           | table | edumeet
 public | groups               | table | edumeet
 public | knex_migrations      | table | edumeet
 public | knex_migrations_lock | table | edumeet
...


