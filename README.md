# ![eduMEET](/images/logo.edumeet.svg) in Docker container


# How to build 
edumeet-docker - include install setps for docker compose and configs -> build edumeet (server+client)

## documentation for configs are version specific default values can be found on release branches on 
- [client](https://github.com/edumeet/edumeet-client/)
- [redis](https://github.com/edumeet/edumeet-client/tree/release-4.0)  only needed for 4.0 
- [room-server config](https://github.com/edumeet/edumeet-room-server) 

## documentation for docker build and run
##  edumeet docker hub with prebuilt release images

#How Branches work: 
- -release-4.0 (this shoud be the same for client and server too for production)
- -main-dev (yourdevbranch(es) for local dev) - link repo localy or add some remote branch 

## Things that docker can build :
- edumeet-client - client side
- edumeet-room-server - server side 
- edumeet-translator - translation page 



Docker hub repository: [edumeet/edumeet](https://hub.docker.com/r/edumeet/edumeet)

This is the container, or a "dockerized" version of the [eduMEET](https://github.com/edumeet/edumeet).
(Successor of [multiparty meeting](https://github.com/havfo/multiparty-meeting) fork of mediasoup-demo)


## Ports and firewall
| Port | protocol | description |
| ---- | ----------- | ----------- |
|  443 | tcp | default https webserver and signaling - adjustable in `server/config/config.yaml`) |
| 4443 | tcp | default `yarn start` port for developing with live browser reload, not needed in production environments - adjustable in app/package.json) |
| 40000-49999 | udp, tcp | media ports - adjustable in `server/config/config.yaml` |

## Load balanced installation

To deploy this as a load balanced cluster, have a look at [HAproxy](HAproxy.md).

## Learning management integration

To integrate with an LMS (e.g. Moodle), have a look at [LTI](LTI/LTI.md).

## TURN configuration

If you are part of the GEANT eduGAIN, you can request your turn api key at [https://turn.geant.org/](https://turn.geant.org/)
	
You need an additional [TURN](https://github.com/coturn/coturn)-server for clients located behind restrictive firewalls! 
Add your server and credentials to `server/config/config.yaml`


## Run it in few easy steps

1. Git clone this code to your docker machine.

2. Run once `update-config.sh` which will download current `app` and `server` `config.example.js` files from main edumeet repository.
    - if there are no existing config.js files, script will automatically generate them.

3. Run once `gen-redis-password.sh` to generate a random password for redis
    - only on the first run, generated password will be automatically set in both redis.conf and edumeet config.yaml files.

4. Copy server certificate to `configs/certs/cert.pem` and private key to `configs/certs/key.pem`
    - to generate a new (unsigned) certificate and private key, use: (note -nodes flag, which allows to generate unencrypted private key)

```sh
        $ openssl req -x509 -newkey rsa:4096 -keyout privkey.pem -out cert.pem -days 365 -nodes
```
5. Custom server configuration could be in `yaml` (recomended), `json`, or `toml` file format. **NOTICE: Use only one!!!**
    - In case `yaml` file format i used, copy `config.example.yaml` to `config.yaml`
    - minimal options which has to be set in configs/server/config.yaml:

```yaml
    listeningPort: 443
    listeningHost: host.domain.tld

    fileTracker" : "wss://tracker.openwebtorrent.com"

    tls:
        cert: /opt/edumeet/server/certs/cert.pem
        key:  /opt/edumeet/server/certs/privkey.pem

    turnAPIURI: "https://host.domain.tld/turn"
    turnAPIKey: "Your API key"

    backupTurnServers:
    - urls:
        - "turn:host.domain.tld:443?transport=tcp"
        username: "Your username"
        credential: "Your's credential"

    redisOptions:
        host: "127.0.0.1"
        port: "6379"
        password: "_REDIS_PASSWORD_"
```
- In case `json` file format is used, copy `config.example.json` to `config.json`
- minimal options which has to be set in configs/server/config.json:
 
 ```json
    {
        "listeningPort" : "443",
        "listeningHost" : "host.domain.tld",

        "fileTracker" : "wss://tracker.openwebtorrent.com",

        "tls" : {
            "cert" : "/opt/edumeet/server/certs/cert.pem",
            "key"  : "/opt/edumeet/server/certs/privkey.pem"
        },

        "turnAPIKey" : "Your API key",
        "turnAPIURI" : "https://host.domain.tld/turn",

        "backupTurnServers" : {
            "urls": [ "turn:host.domain.tld:443?transport=tcp" ],
            "username" : "Your username",
            "credential" : "Your's credential"
        },

        "redisOptions": {
            "host" : "127.0.0.1",
            "port" : "6379",
            "password" : "_REDIS_PASSWORD_"
        }
    }
```
- In case `toml` file format is used, copy `config.example.toml` to `config.toml`
- minimal options which has to be set in configs/server/config.toml:

```toml
    listeningPort = "443"
    listeningHost = "host.domain.tld"
    fileTracker = "wss://tracker.openwebtorrent.com"
    turnAPIKey = "Your API key"
    turnAPIURI = "https://host.domain.tld/turn"

    [tls]
    cert = "/opt/edumeet/server/certs/cert.pem"
    key = "/opt/edumeet/server/certs/privkey.pem"

    [backupTurnServers]
    urls = [ "turn:host.domain.tld:443?transport=tcp" ]
    username = "Your username"
    credential = "Your's credential"

    [redisOptions]
    host = "127.0.0.1"
    port = "6379"
    password = "_REDIS_PASSWORD_"
```
- `host.domain.tld` has to be replaced by server's IP address or FQDN
- _REDIS_PASSWORD_ will be replaced automatically during step 3

**Recommended:**
- set TURN server and credential in `configs/server/config.yaml`
- in case of using coturn, generate a user and key with

```sh
        $ turnadmin -k -u <username> -p <password>
```
Placeholder looks like:

```yaml
    turnAPIURI: "https://HOST.DOMAIN.TLD/turn"
    turnAPIKey: "Your API key"

    backupTurnServers:
    - urls:
        - "turn:HOST.DOMAIN.TLD:443?transport=tcp"
        username: "username"
        credential: "credential"
```

- HOST.DOMAIN.TLD has to be replaced by server's IP or FQDN
- "username" is previously used `<username>`, and "credential" is the code generated by the above mentioned command (step 3).

**Optional:**
- replace logo/logo.edumeet.svg with your company logo svg.
- sort audio/video codecs according to preference.

## Run

Run with `docker-compose` 
/ [install docker compose](https://docs.docker.com/compose/install/) /

```sh
  $ sudo docker-compose up --detach
```
- edumeet and redis images will be pooled from Docker hub
- **note**: to enable automatic Docker images update, uncomment `ouroboros` configuration in `docker-compose.yml`

## Rebuild

To rebuild edumeet docker image (eg. change in .env) use following command:

```sh
  $ sudo docker-compose -f docker-compose-build.yml build
```

## 2 Docker networking

Container works in "host" network mode, because bridge mode has the following issue: ["Docker hangs when attempting to bind a large number of ports"](https://success.docker.com/article/docker-compose-and-docker-run-hang-when-binding-a-large-port-range)

## Further Informations

Read more about configs and settings in [eduMEET](https://github.com/edumeet/edumeet) README.

