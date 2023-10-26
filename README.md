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
  - [edumeet-management-server](https://github.com/edumeet/edumeet-management-server)
  - [edumeet-management-client](https://github.com/edumeet/edumeet-management-client)

In edumeet-docker components are linked together via the edumeet-client docker image.

The edumeet-client docker image uses an nginx proxy to serve most of the other components.

By default it is using the built in docker networking hostnames to connect/link components.

Since some components need the hostname / domain name / IP to function it is included in every config and can be changed depending on the use case.

It also makes certificate renewal easy since on a single domain setup you only need to change the cert in the certs folder.

- "edumeet-management-client:emc"
- "keycloak:kc"
- "edumeet-room-server:io"
- "edumeet-management-server:mgmt"
- "pgadmin:pgadmin"

Edumeet media node currently uses a certificate without the proxy, in a more direct way because it needs host network see the bottom of the repository.

 # ![Architecture](/images/arch-white.drawio.png)


# Install dependencies
```bash
sudo apt install jq ack
```
Install docker V2

```bash
https://docs.docker.com/engine/install/debian/#install-using-the-repository
```
Optional (add current user to docker group )
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```


# Update, configure, build and run.
## Clone repository to your (docker) host, and cd into the folder:
```bash
git clone https://github.com/edumeet/edumeet-docker.git
cd edumeet-docker
```


#  Configure
## Step 1: 
* Edit docker-compose.yml for services that you want.
* Set your domain name in .env file

## Step 2: 
* start `run-me-first.sh` script. This script will download newest Dockerfile(s) and config.example.* files from the repository.
```
./run-me-first.sh
```

## Step 3: 
* Set your desired release branch in .env file. Branch names (for example 4.0) should match for client and server side.

Change configs to your desired configuration.
By default (single domain setup):
```
- configs/server/config.json
   **remove tls options (behind proxy it is not needed)**
  'host' should be 'http://mgmt:3030',
  'hostname' should be your domain name   'edumeet.example.com',
- configs/app/config.js
   managementUrl should be domain name 'https://edumeet.example.com/mgmt'

Change domain in the following files:
configs/kc/dev.json:535:    "rootUrl" : "https://edumeet.example.com/",
configs/kc/dev.json:536:    "adminUrl" : "https://edumeet.example.com/mgmt/*",
configs/mgmt-client/config.js:3:    serverApiUrl: "https://edumeet.example.com/mgmt",
configs/mgmt-client/config.js:4:    hostname: "https://edumeet.example.com",
configs/mgmt/default.json:30:                   "audience": "https://edumeet.example.com/",
configs/mgmt/default.json:42:                           "redirect_uri": "https://edumeet.example.com/mgmt/oauth/tenant/callback"
configs/nginx/default.conf:84:  #server_name  edumeet.example.com;
.env:2:EDUMEET_DOMAIN_NAME=edumeet.example.com
configs/server/config.json:9:           "host": "http://localhost:3030",
configs/server/config.json:15:          "hostname": "localhost",
configs/app/config.js:11:       managementUrl: 'http://localhost:3030',
```
- Additional configuration documentation is located in [edumeet-client](https://github.com/edumeet/edumeet-client/) and [edumeet-room-server](https://github.com/edumeet/edumeet-room-server) repositories.

NOTE! Certficates are selfsigned, for a production service you need to set YOUR signed certificate in nginx and  server configuration files
`in nginx/default.conf`
```bash
  server_name  edumeet.example.com; 
  ssl_certificate     /etc/edumeet/edumeet-demo-cert.pem;
  ssl_certificate_key /etc/edumeet/edumeet-demo-key.pem; 
```
### Download or build images (run-me-first generates the latest ones):
```
docker pull edumeet/edumeet-media-node:TAG
docker pull edumeet/edumeet-room-server:TAG
docker pull edumeet/edumeet-client:TAG
...
```

## Run

Run with `docker-compose` 
/ [install docker compose](https://docs.docker.com/compose/install/) /

```sh
  $ sudo docker-compose up --detach
```
To build: 
1. change TAG in .env file to your desired name.
2. Build and run:
```sh
  $ sudo docker-compose build
  $ sudo docker-compose up -d
```

## Initial setup after first run
1. visit yourdomain/kc/ and set up your keycloak instance
By default there is a dev configuration according to https://github.com/edumeet/edumeet-management-server/wiki/Keycloak-setup-(OAuth-openid-connect)

By default there is one test user in dev realm :
- Username: edumeet
- Password: edumeet
2. visit yourdomain/cli/ and set up your management server config
   - add a tenant
   - add a tenant fqdn / domain
   - add authetntication
 # ![auth](/images/mgmt-client-setup-1.png)

     
3. Logout 
4. Visit your domain (Login)
5. Visit yourdomain/cli/ and as the logged in user create a room
6. Join the room


## Default ports for firewall setting
| Port | protocol | description | network | path |
| ---- | ----------- | ----------- | ----------- | ----------- |
|  80 | tcp | edumeet-client webserver (redirect to 443) | host network (proxy) | / | 
|  443 | tcp | edumeet-client https webserver and signaling proxy | host network (proxy) |  / |
|  3000 |  | edumeet-media-node port | host network | - |
|  8000 | tcp | edumeet-room-server webserver and signaling | host network (proxy) | /mgmt/ |
|  40000-49999 | udp | edumeet-media-node ports | host network | - |
| | | | | |
|  3000 | tcp | edumeet-management-server port | docker internal only (available via proxy) | /mgmt/ |
|  3002 | tcp | edumeet-management-cli port | docker internal only (available via proxy) | /cli/ |
|  8080 | tcp | keycloak | docker internal only (available via proxy) | /kc/ |
|  5050 | tcp | pgAdmin | internal only (available via proxy) | /pgadmin4/ |
|  5432 | tcp | edumeet-db | docker internal only | - |


## Docker networking
edumeet-room-server container works in "host" network mode, because bridge mode has the following issue: ["Docker hangs when attempting to bind a large number of ports"](https://success.docker.com/article/docker-compose-and-docker-run-hang-when-binding-a-large-port-range)


