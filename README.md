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

### In general this architecture can be scaled and can consinst of many of the components.

Media nodes can be selected with GeoIP.

Edumeet-client frontends can run on many different servers.

Management server can host many tenants/domains. The management server database can be clustered.

Keycloak can support a number of Realms.

 # ![General Architecture](/images/general-arch.png)

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
git checkout <branch>
```


#  Configure
## Step 1: 
* start `run-me-first.sh` script. This script will download newest Dockerfile(s) and config.example.* files from the repository.
```
./run-me-first.sh
```

#### Set your domain name in .env file
```
SET DOMAIN NAME (edumeet.example.com): yourdomain.com
```

The run-me-first.sh will scan for files with the default example domain/localhost occurances that shoud be changed:   
```
configs/app/config.js:11:       managementUrl: 'http://localhost:3030',
...
```
There are automated steps to change the configs:
```
Do you want to remove tls option from server/config.json (recommended)? [Y/n] y
done

Do you want to set host configuration to domain name from .env file and docker hostname to mgmt in server/config.json (recommended)? [Y/n] y
done

Do you want to set managementUrl to https://edumeet.sth.sze.hu/mgmt from .env file in app/config.js (recommended)? [Y/n] y
done

Do you want to replace edumeet.example.com domain in management-server config files to edumeet.sth.sze.hu in mgmt/default.json (recommended)?[Y/n] y
done

Do you want to update Keycloak dev realm to your domain : edumeet.sth.sze.hu from .env file in kc/dev.json (recommended)? [Y/n] y
done

Do you want to set up edumeet-management-client to https://edumeet.sth.sze.hu/cli from .env file in mgmt-client/config.js (recommended)? [Y/n] y
done
```
- Additional configuration documentation is located in [edumeet-client](https://github.com/edumeet/edumeet-client/) and [edumeet-room-server](https://github.com/edumeet/edumeet-room-server) repositories.

## Step 2 (Optional): 
### Set your desired release branch in .env file if you wish to run an other branch.
Branch names (for example 4.0) should match for client and server side.

### Edit docker-compose.yml for services that you want.

## Step 3:
### NOTE! Certficates are selfsigned, for a production service you need to set YOUR signed certificate in nginx and  server configuration files:
Update certficates:
`in edumeet-docker/certs/` 

Default cert files:  ( edumeet-demo-cert.pem and edumeet-demo-key.pem)

#### If cert names change you shoud update it in .env:


`KC_HTTPS_CERTIFICATE_FILE,
KC_HTTPS_CERTIFICATE_KEY_FILE`

and 

`MN_EXTRA_PARAMS='--cert ./certs/edumeet-demo-cert.pem --key ./certs/edumeet-demo-key.pem'`

and 


`in nginx/default.conf` :
```bash
  server_name  edumeet.example.com; 
  ssl_certificate     /etc/edumeet/edumeet-demo-cert.pem;
  ssl_certificate_key /etc/edumeet/edumeet-demo-key.pem; 
```

## Step 4 Run:
Run with `docker compose` 

```sh
  $ sudo docker compose up --detach
```
*without the detach option you will see the logs

To build: 
1. Change TAG in .env file to your desired name.
2. In .env file set to your desired BRANCH.
3. Build and run:
```sh
  $ sudo docker compose build
  $ sudo docker compose up -d
```

## Step 5 Initial setup after first run:
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
| Port | protocol | description | network | path | firewall advice | 
| ---- | ----------- | ----------- | ----------- | ----------- |--------------|
|  80 | tcp | edumeet-client webserver (redirect to 443) | host network (proxy) | / | |
|  443 | tcp | edumeet-client https webserver and signaling proxy | host network (proxy) |  / | |
|  3000 |  | edumeet-media-node port | host network | - | should be limited so only the room-server can access it |
|  3002 | tcp | edumeet-management-cli port | host network (proxy) | /cli/ | |
|  8443 | tcp | edumeet-room-server webserver and signaling | host network (proxy) | /mgmt/ | |
|  40000-49999 | udp | edumeet-media-node ports | host network | - | |
| | | | | |
|  3000 | tcp | edumeet-management-server port | docker internal only (available via proxy) | /mgmt/ | |
|  3002 | tcp | edumeet-management-cli port | docker internal only (available via proxy) | /cli/ | |
|  8080 | tcp | keycloak | docker internal only (available via proxy) | /kc/ | administrator access should be limited |
|  5050 | tcp | pgAdmin | internal only (available via proxy) | /pgadmin4/ | administrator access should be limited OR turned off if not needed|
|  5432 | tcp | edumeet-db | docker internal only | - | |


## Docker networking
edumeet-room-server container works in "host" network mode, because bridge mode has the following issue: ["Docker hangs when attempting to bind a large number of ports"](https://success.docker.com/article/docker-compose-and-docker-run-hang-when-binding-a-large-port-range)

## FAQ
Q: I get "Cannot find module erros" regarding config files

A: You are probably having a relative path issue with docker check if you are in the correct directory. (edumeet-docker folder)

