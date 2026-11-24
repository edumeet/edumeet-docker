# Full Docker deployment: authentication

The stack can run unmanaged rooms without login. To use managed rooms and
identity-provider login, configure the management server and an OpenID Connect
(OIDC) provider. The included Keycloak service can act as a provider; other
OIDC-compatible providers can also be used.
For federated login with discovery, the existing deployment guidance suggests
SATOSA as an identity-provider gateway.

## Production warning

> **Do not use the bundled Keycloak service as your production identity
> provider or user database.** It is included to demonstrate user management
> and OIDC integration in the eduMEET Docker environment, not as a
> production-ready identity deployment. If production accounts will rely on
> Keycloak, deploy and operate your own production-ready Keycloak service
> separately, with appropriate security hardening, durable storage, backups,
> monitoring, upgrades and availability. Operating a production identity
> provider is outside the scope of the eduMEET project.

## Initial setup

1. Sign in to `https://<main-domain>/kc/` and set up a Keycloak realm and
   confidential client, or prepare another OIDC provider. See the
   [Keycloak setup guide](https://github.com/edumeet/edumeet-management-server/wiki/Keycloak-setup-(OAuth-openid-connect)).
2. Sign in to `https://<main-domain>/mgmt-admin/` with the management
   administrator credentials configured during installation.
3. Create a tenant and its FQDN. Configure its OIDC provider using the
   provider's discovery URL and **Update Parameters from URL**, or enter the
   endpoints and client credentials manually. For Keycloak the discovery URL is
   `https://<main-domain>/kc/realms/<realm>/.well-known/openid-configuration`;
   use the client ID as the key and the Keycloak client secret as the secret.
   The tenant FQDN must match the domain users visit.
4. Sign out and test login through the configured tenant domain. Create a room
   in the management UI and join it.

Use unique, strong credentials; do not reuse example credentials in an exposed
deployment. Provider secrets belong in the management configuration, not in
public documentation.

For the default Docker setup, register
`https://<main-domain>/mgmt/oauth/tenant/callback` as an allowed redirect URI
at the provider. If you configure a different redirect URI, it must match
there and in the tenant's OAuth settings. For an identity provider on a
private network, the management server needs its hostname explicitly allowed
in `oauthPrivateHosts`; only allow hosts you trust.

Provider screens and field labels vary. Use the callback URI above and the
provider's current discovery metadata or endpoint values.

## Check login

In a private browser window, visit the tenant domain and sign in with a
dedicated test account. Confirm that the provider redirects back, the account
is signed in, and sign-out works. Do not use the management super-admin as an
OIDC test account.

Browser automation should wait for the provider and login state rather than a
fixed delay. Avoid passing passwords on command lines, where other local users
or shell history may expose them; protect screenshots and logs that could
contain account information. Certificate-bypass flags are for isolated test
environments only.

## Proxy and login throttling

The management server limits failed local login attempts per IP address. This
applies to the super-admin form and the room server's management login. After
10 failures in 15 minutes, that IP receives HTTP 429 for 15 minutes. Failures
are logged at `warn`; successful logins are not counted.

In this Docker stack the management server runs behind Nginx, so
`TRUST_PROXY=true` is set in `.env` by default. With it enabled, the server
uses the rightmost `X-Forwarded-For` address supplied by the proxy; otherwise
it uses the TCP peer. Keep the proxy and trust configuration aligned so the
throttle sees the client IP. If the management server is exposed directly
without a trusted proxy, set `TRUST_PROXY=false`; otherwise a client can spoof
the forwarded address.

For certificate requirements, see [certificates](certificates.md).
