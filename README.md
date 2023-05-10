# ![eduMEET](/images/logo.edumeet.svg) in Docker container
Docker hub repository: [edumeet/edumeet](https://hub.docker.com/r/edumeet/edumeet)

This is "dockerized" version of the [eduMEET](https://github.com/edumeet/edumeet).
(Successor of [multiparty meeting](https://github.com/havfo/multiparty-meeting) fork of mediasoup-demo)

It will setup a production eduMEET instance, and help you with setting up a development environment.

For further (more generic) information take a look at [eduMEET repository](https://github.com/edumeet/edumeet)

# Architecture
- Current stable eduMEET consists of these components:
  - [edumeet-client](https://github.com/edumeet/edumeet-client/)
  - [edumeet-room-server](https://github.com/edumeet/edumeet/tree/master/server)) from edumeet-repo /server folder
- Next generation eduMEET:
  - [edumeet-client](https://github.com/edumeet/edumeet-client/)
  - [edumeet-room-server](https://github.com/edumeet/edumeet-room-server)
  - [edumeet-media-node](https://github.com/edumeet/edumeet-media-node)


## Docker images that will be created:
- edumeet-client - client side
- edumeet-room-server - server side
- optional edumeet-translator - a web service to help to generate translation files

# Update, configure, build and run.
## Clone repository to your (docker) host, and cd into the folder:
```bash
git clone https://github.com/edumeet/edumeet-docker.git
cd edumeet-docker
```
## `run-me-first.sh` - update and set configuration files
Step 1: Set your desired release branch in .env file. Branch names (for example 4.0) should match for client and server side.

Step 2: start `run-me-first.sh` script. This script will download newest Dockerfile(s) and config.example.* files from the repository, also it will generate and set Redis password.
```
./run-me-first.sh

```

Step 3: Configure `configs/app/config.js`, `configs/server/config.json`, `configs/nginx/default.conf`

- Additional configuration documentation is located in [edumeet-client](https://github.com/edumeet/edumeet-client/) and [edumeet-room-server](https://github.com/edumeet/edumeet-room-server) repositories.

NOTE! Certficates are selfsigned, for a production service you need to set YOUR signed certificate in nginx and  server configuration files

`in nginx/default.conf`
```bash
  server_name  edumeet.example.com; 
  ssl_certificate     /etc/edumeet/edumeet-demo-cert.pem;
  ssl_certificate_key /etc/edumeet/edumeet-demo-key.pem; 
```
`in server/config.json`
```json
    "tls" : {
      "cert" : "./certs/edumeet-demo-cert.pem",
      "key"  : "./certs/edumeet-demo-key.pem"
    },
```

## Edit docker-compose.yml for services that you want 
* required  edumeet-room-server
* required  edumeet-client
* optional  edumeet-translator

## download images :
```
docker pull edumeet/edumeet-media-node:4.x-20230510-nightly
docker pull edumeet/edumeet-room-server:4.x-20230510-nightly
docker pull edumeet/edumeet-client:4.x-20230510-nightly
```

## Edit nginx config and server config.json with the ip of the server
# nginx example
    proxy_pass          http://<ip>:<port of the server>;
    -> 
    proxy_pass          http://172.24.208.161:8000;
# server example
```
{
	"listenPort": "8000",
	"listenHost": "172.24.208.161",
	"mediaNodes": [{
		"hostname": "localhost",
		"port": 3000,
		"secret": "secret-shared-with-media-node",
		"latitude": 63.430481,
		"longitude": 10.394964
	}]
}
```
## Run

Run with `docker-compose` 
/ [install docker compose](https://docs.docker.com/compose/install/) /

```sh
  $ sudo docker-compose up --detach
```
- TODO : edumeet images will be pooled from Docker hub

## Default ports for firewall setting
| Port | protocol | description |
| ---- | ----------- | ----------- |
|  80 | tcp | edumeet-client webserver (redirect to 443) |
|  443 | tcp | edumeet-client https webserver and signaling proxy |
|  8002 | tcp | edumeet-room-server webserver and signaling |
|  40000-49999 | udp | edumeet-room-server media ports |

If other ports are required, they have to be set in configuration files and exposed Dockerfiles


## Load balanced installation

To deploy this as a load balanced cluster, have a look at [HAproxy](HAproxy.md).

## Learning management integration

To integrate with an LMS (e.g. Moodle), have a look at [LTI](LTI/LTI.md).

## TURN configuration

For clients located behind restrictive firewalls, You will need an additional [TURN](https://github.com/coturn/coturn)-server 
Add your server and credentials to `server/config/config.json`

```json
    "turnAPIKey" : "Your API key",
    "turnAPIURI" : "https://host.domain.tld/turn",
```
If you are [eduGAIN](https://edugain.org/) member, you can generate your turn api key at [https://turn.geant.org/](https://turn.geant.org/)

## Docker networking

edumeet-room-server container works in "host" network mode, because bridge mode has the following issue: ["Docker hangs when attempting to bind a large number of ports"](https://success.docker.com/article/docker-compose-and-docker-run-hang-when-binding-a-large-port-range)

## Building images locally for Development
In order to build docker images you can uncomment the build-sections in `docker-compose.yml` for the images you want. 

## Further Informations

Read more about configs and settings in [eduMEET](https://github.com/edumeet/edumeet) README.

