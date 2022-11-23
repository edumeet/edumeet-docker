# ![eduMEET](/images/logo.edumeet.svg) in Docker container
This is the docker building repo for eduMEET. It can setup a production instance of eduMEET and help you with setting up a development enviroment as well.

For more generic information look here:

main [eduMEET repo](https://github.com/edumeet/edumeet) with generic documentation

# Architecture
- Current stable eduMEET consists of these components:
  - [edumeet-client](https://github.com/edumeet/edumeet-client/) 
  - [room-server](https://github.com/edumeet/edumeet/tree/master/server)) from edumeet-repo /server folder
- Next generation eduMEET:
  - [edumeet-client](https://github.com/edumeet/edumeet-client/)
  - [room-server](https://github.com/edumeet/edumeet-room-server)
  - [edumeet-media-node](https://github.com/edumeet/edumeet-media-node)


# How branches work: 
- release branch names like 4.0 shoud match for client side and server side too.
- for example release-4.0 is production ready release branch, the install steps are in Dockerfile .
- releases also contiain Dockerfile-dev files (that are for local development) - link repo localy or specify remote branch to run 
- documentation for configs can be found on the separate repos like edumeet/edumeet-client .  

## Things that edumeet-docker can build :
- edumeet-client - client side
- edumeet-room-server - server side 
- edumeet-translator - translation page 


# Update, configure, build and run.
## Git clone this code to your docker machine.
```bash
git clone https://github.com/edumeet/edumeet-docker.git
```

## Run update  
Set your desired release branch. For example 4.0-release in the .env file.

Update with update-config.sh. (This will get the newest dockerfiles and config.examples from the branches)
```
./update-config.sh
```
## Configure [nginx.conf](https://github.com/edumeet/edumeet-docker/blob/4.x/nginx/nginx.conf) in nginx folder.
 
Change configuration url and update certs. 
```bash
  server_name  edumeet.example.com; 
  listen 443 ssl;
  listen [::]:443 ssl;
  ssl_certificate     /srv/edumeet/edumeet-demo-cert.pem;
  ssl_certificate_key /srv/edumeet/edumeet-demo-key.pem;
```

Copy [configs/app/config.example.js](https://github.com/edumeet/edumeet-docker/tree/4.x/configs/app) to configs/app/config.js
```bash
cp configs/app/config.example.js configs/app/config.js
```
Copy [configs/server/config.example.json](https://github.com/edumeet/edumeet-docker/tree/4.x/configs/server) to configs/server/config.json
```bash
cp configs/server/config.example.json configs/server/config.json
```

### for 4.0 you shoud use : 
Copy [configs/server/config.example.js](https://github.com/edumeet/edumeet-docker/tree/4.x/configs/server) to configs/server/config.js
```bash
cp configs/server/config.example.js configs/server/config.js
```
Copy [configs/server/config.example.yaml](https://github.com/edumeet/edumeet-docker/tree/4.x/configs/server) to configs/server/config.yaml
```bash
cp configs/server/config.example.yaml configs/server/config.yaml
```

Optional update config files.

## Edit docker-compose for services that you want 
* required  edumeet-room-server
* required  edumeet-client
* optional edumeet-translator


## Run

Run with `docker-compose` 
/ [install docker compose](https://docs.docker.com/compose/install/) /

```sh
  $ sudo docker-compose up --detach
```
- TODO : edumeet images will be pooled from Docker hub

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

## Docker networking

Container works in "host" network mode, because bridge mode has the following issue: ["Docker hangs when attempting to bind a large number of ports"](https://success.docker.com/article/docker-compose-and-docker-run-hang-when-binding-a-large-port-range)

## Further Informations

Read more about configs and settings in [eduMEET](https://github.com/edumeet/edumeet) README.

