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


# Update, configure, build and run.
## Clone repository to your (docker) host, and cd into the folder:
```bash
git clone https://github.com/edumeet/edumeet-docker.git
cd edumeet-docker
```
# Install dependencies
```bash
sudo apt install jq docker docker-compose ack
```

https://docs.docker.com/engine/install/debian/#install-using-the-repository

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y 
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

Optional (add current user to docker group )
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

#  Configure
## Step 1: 
* Edit docker-compose.yml for services that you want.
* Set your domain name in .env file

## Step 2: 
* start `run-me-first.sh` script. This script will download newest Dockerfile(s) and config.example.* files from the repository, also it will generate and set Redis password.
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
  'host' shoud be 'http://mgmt:3030',
  'hostname' shoud be your domain name   'edumeet.example.com',
- configs/app/config.js
   managementUrl shoud be domain name 'https://edumeet.example.com/mgmt'

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
# Download or build images (run-me-first generates the latest ones):
```
docker pull edumeet/edumeet-media-node:4.x-20230510-nightly
docker pull edumeet/edumeet-room-server:4.x-20230510-nightly
docker pull edumeet/edumeet-client:4.x-20230510-nightly
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
There is one test user :
- Username: edumeet
- Password: edumeet
2. visit yourdomain/cli/ and set up your management server config
   - add a tenant
   - add a tenant fqdn / domain
   - add authetntication
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

## Building images locally for Development
In order to build docker images you can uncomment the build-sections in `docker-compose.yml` for the images you want. 

## Further Informations
Read more about configs and settings in [eduMEET](https://github.com/edumeet/edumeet) README.

