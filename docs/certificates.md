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

## Development placeholder

The helper is only for bootstrapping the proxy:

```bash
./utils/gen_dev_cert.sh
```

The script creates a one-day self-signed placeholder certificate with
`CN=localhost`; it does not create a certificate for your configured domains or
make browsers trust it. Do not use it as a production certificate. To use local
HTTPS, provide a certificate with subject alternative names for both domains
and trust that certificate or its signing CA on the test clients. TURN over TLS
clients must trust the certificate presented by the proxy too.

The media node uses a separate certificate pinned by the room server. See
[addresses and NAT](networking.md#addresses-and-nat) when its listen IP changes.

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
