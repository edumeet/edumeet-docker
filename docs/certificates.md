# Full Docker deployment: certificates

For production, the Nginx proxy needs a certificate trusted by users' browsers
and covering both the main domain and the TURN media domain. Nginx reads its certificate paths
from [`configs/proxy/nginx.conf.template`](../configs/proxy/nginx.conf.template).
For manually supplied certificates, make the files and template paths agree.

## Let's Encrypt

After configuration, ensure both domains resolve to the server and TCP port 80
is reachable for HTTP validation. Then run:

```bash
./utils/gen_cert.sh
```

The script starts all services, because the proxy only starts when the services
it forwards to are running, and waits until the proxy answers before it requests
the certificate.

The script can replace existing certificate data after confirmation; back it up
before rerunning the script. It uses the lowercase shell variable `email` when
choosing a Certbot email argument; check the resulting Certbot registration
before relying on email notifications. The fix for the related
[minimal setup issue](https://github.com/edumeet/edumeet/issues/1127) does not
change this separate full-Docker script.
The script requests a forced renewal. For testing, change `staging=0` to
`staging=1` in the script to use Let's Encrypt's staging service and avoid
production rate limits; staging certificates are not trusted by browsers.

For automatic renewal, set `USE_CERTBOT=true` in `.env` and start or recreate
the Compose services. The certbot container checks for renewals every 12 hours;
check its logs and confirm renewal works in your environment.

## Development certificate

For a test setup without a certificate from a public CA:

```bash
./utils/gen_dev_cert.sh
```

The script creates a self-signed certificate that names both configured
domains and is valid for 30 days. Browsers do not trust it, so do not use it in
production. To use it for local HTTPS, trust the certificate on the test
clients; TURN over TLS clients must trust it too. The script also copies the
certificate to `certs/extra-ca/dev-cert.pem` and prints the
`NODE_EXTRA_CA_CERTS` line to set in `.env`; without that line, signing in
through the Keycloak of this setup fails with this certificate. See
[certificate verification](#certificate-verification).

The media node uses a separate certificate pinned by the room server. See
[addresses and NAT](networking.md#addresses-and-nat) when its listen IP changes.

## Certificate verification

The room server, media node and management server verify the TLS certificate of
every server they connect to: the identity provider of a tenant, the SMTP/IMAP
servers for calendar invites, bot providers and upload targets.
`docker-compose.yml` sets `NODE_TLS_REJECT_UNAUTHORIZED=1` for them, and a value
in `.env` does not change that.

If one of those servers has a certificate from a private or self-signed CA,
trust that CA instead of switching verification off: put its certificate (PEM)
in `certs/extra-ca/`, set `NODE_EXTRA_CA_CERTS=/certs/extra-ca/<file>` in `.env`
and run `docker compose up -d`.

Upgrading from 4.2-20261118-stable or older: `.env` used to contain
`NODE_TLS_REJECT_UNAUTHORIZED=0`, which accepted any certificate, so anyone able
to intercept the connection to the identity provider could sign in as any user
of the tenant. Delete that line from your `.env`. If sign-in, invite mail or a
bot provider fails afterwards with a certificate error (`unable to verify the
first certificate`, `self-signed certificate`), that server needs a valid
certificate or its CA in `certs/extra-ca/` as described above.

## HTTPS only (HSTS)

The proxy sends this header with every HTTPS answer, from the HTTPS server block of
`configs/proxy/nginx.conf.template`:

```nginx
add_header Strict-Transport-Security "max-age=31536000" always;
```

HSTS tells browsers that have visited over HTTPS to use HTTPS on later visits, for a year.
Without it, an attacker on the visitor's network can answer a plain HTTP request for the site
with a page of their own, before the redirect to HTTPS. It does not protect the first visit.

### What it changes for you

A browser stores the policy for the host name at its first visit over HTTPS and keeps it for a
year after its last visit. For that browser:

- **Nothing on this host name opens over plain HTTP any more, on any port.** The browser
  changes `http://<name>:<port>/` to `https://<name>:<port>/` before it sends anything. If
  another service is reached as `http://<the same name>:<port>` (a monitoring page, another
  application), give it HTTPS or another host name before you upgrade, or switch the header off
  as described below.
- **A certificate error cannot be passed.** If the certificate expires or does not match, the
  browser shows an error without the button to continue. Check that the renewal works: see the
  log of the `certbot` service, and renew in time if you use your own certificate.
- **Going back to HTTP takes time.** Removing the header does not make browsers forget the
  policy; see below.

Not affected:

- A self-signed development certificate. A browser ignores the header when it does not trust
  the certificate. A development certificate from a CA that the browser trusts is affected.
- Other host names, also subdomains: the header does not carry `includeSubDomains`. Do not add
  `includeSubDomains` or `preload` unless every affected domain is ready for HTTPS.
- Programs that are not browsers, such as the Let's Encrypt validation on port 80.

Keycloak sends its own HSTS header on the pages under `/kc`, by default with
`includeSubDomains`. A site that offers sign-in through the bundled Keycloak has had the policy
in the browsers of its users before this change. The realm setting is under *Realm settings*,
*Security defenses*.

### Switching it off

- **Before any browser has seen it:** comment the `add_header` line out in
  `configs/proxy/nginx.conf.template` and restart the proxy (`docker compose restart proxy`).
- **After browsers have seen it:** set the value to `max-age=0`, restart the proxy and leave it
  like that for as long as visitors may come back. A browser drops the policy when it receives
  this value over HTTPS. Only then comment the line out.
- **To try it first:** use a short value such as `max-age=300`.

An installation with its own copy of the template gets the header only when it takes the line
over. If another proxy fronts eduMEET, configure HSTS there for each tenant domain as well.
