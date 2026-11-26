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

With valid production certificates, you can enable HSTS by uncommenting this
line in the HTTPS server block of `configs/proxy/nginx.conf.template`:

```nginx
add_header Strict-Transport-Security "max-age=31536000" always;
```

HSTS tells browsers that have visited over HTTPS to use HTTPS on later visits.
This helps protect later visits from an attacker intercepting an HTTP request
before the redirect, but it does not protect the first visit. Start with a
shorter value such as `max-age=300` while testing. Leave it off for development certificates or
domains that may need HTTP: browsers remember the policy and will not let users
bypass certificate errors. Do not add `includeSubDomains` or `preload` unless
every affected domain is ready for HTTPS. If another proxy fronts eduMEET,
configure HSTS there for each tenant domain as well.
