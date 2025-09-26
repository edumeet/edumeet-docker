# ![eduMEET](/images/logo.edumeet.svg) in Docker container

This is "dockerized" version of the [eduMEET](https://github.com/edumeet/edumeet). 
(Successor of [multiparty meeting](https://github.com/havfo/multiparty-meeting) fork of mediasoup-demo)

Docker hub repository: [edumeet](https://hub.docker.com/u/edumeet)

It will setup a production eduMEET instance with or without authentication, and help you with setting up a development environment.

For further (more generic) information take a look at [eduMEET repository](https://github.com/edumeet/edumeet)
_________________

- Current stable eduMEET consists of these components:
  - [edumeet-client](https://github.com/edumeet/edumeet-client/)
  - [edumeet-room-server](https://github.com/edumeet/edumeet-room-server)
  - [edumeet-media-node](https://github.com/edumeet/edumeet-media-node)
  - [edumeet-management-server](https://github.com/edumeet/edumeet-management-server)

Setup guide in a video format can be found here: 
[![Watch the video](https://img.youtube.com/vi/wtsRKQEZv9k/maxresdefault.jpg)](https://youtu.be/wtsRKQEZv9k)

> FAQ is at the bottom of this README.md !

## Guides (click to open):
<details>
  <summary>Recommended configuration + introduction</summary>
  
### Recommended configuration of VM / server:
|   | Specs | 
| ---- | ----------- |
|  CPU | typical modern CPU (8 cores) | 
|  RAM | 8 GB | 
|  HDD | 100GB | 
|  network | 1 network adapter (1Gb/s) | 
| OS | Ubuntu / Debian | 
|| public IP address (without any NAT) |
|| 2 FQDN name assigned (for certificates) |

In edumeet-docker components are linked together via the proxy (nginx) docker image.

By default it is using the docker networking hostnames to connect/link components.

Since some components need the hostname / domain name / IP to function it is included in every config and can be changed depending on the use case.

It also makes certificate renewal easy since on a single domain setup you only need to change the cert in the certs folder.

eduMEET client is the frontend, room-server is the backend, management-server is the auth backend, media-node is used for everything media related.

 # ![General Architecture](/images/edumeet_general_component_functions.png)

</details>


<details>
  <summary>Architecture</summary>
eduMEET docker uses the following endpoints for components:

 # ![Architecture](/images/edumeet_endpoints.png)


### eduMEET can run from a single host

Components can run on a single machine with docker compose or can be separated.

 # ![Architecture2](/images/edumeet_ways_to_run.png)

### Scaling eduMEET 
Media nodes can be selected with GeoIP. 

Edumeet-client frontends can run on many different servers.

Management server can host many tenants/domains. The management server database can be clustered.

Keycloak can support a number of Realms.

# ![Architecture3](/images/general-arch.png)
 


</details>

<details>
  <summary>Installation ⬅ (Without dependencies, edumeet-docker will probably fail!)</summary>
  
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


##  Update, configure
### Step 1: 
* start `run-me-first.sh` script. This script will download newest Dockerfile(s) and config.example.* files from the repository.
```
./run-me-first.sh
```

#### By running run-me-first.sh your domain names + your IP (you might have to change it it is not your public IP) will be set in the .env file
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

Do you want to set managementUrl to https://yourdomain.com/mgmt from .env file in app/config.js (recommended)? [Y/n] y
done

Do you want to replace edumeet.example.com domain in management-server config files to yourdomain.com in mgmt/default.json (recommended)?[Y/n] y
done

Do you want to update Keycloak dev realm to your domain : yourdomain.com from .env file in kc/dev.json (recommended)? [Y/n] y
done

```
- Additional configuration documentation is located in [edumeet-client](https://github.com/edumeet/edumeet-client/) and [edumeet-room-server](https://github.com/edumeet/edumeet-room-server) repositories.

## Step 2 (Optional): 
### Set your desired release branch in .env file if you wish to run an other branch.
Branch names (for example 4.0) should match for client and server side.

### Edit docker-compose.yml for services that you want.
For example want to separe media node(s) to different servers, or remove the included pgadmin interface.

## Step 3:
### NOTE! Certficates are selfsigned, for a production service you need to set YOUR signed certificate in nginx and  server configuration files:

Certificates are now generated with Let's Encrypt by default with running the gen_cert.sh

Default certficates are in for applications that are behind proxy but still require one to start:
`in edumeet-docker/certs/` 

Default cert files:  ( edumeet-demo-cert.pem and edumeet-demo-key.pem)

#### If cert names change you shoud update it in .env:

`KC_HTTPS_CERTIFICATE_FILE,
KC_HTTPS_CERTIFICATE_KEY_FILE`

and 

`MN_EXTRA_PARAMS='--cert ./certs/edumeet-demo-cert.pem --key ./certs/edumeet-demo-key.pem'`

For proxy certs can be changed in the nginx proxy file:

`in configs/proxy/nginx.conf.template` :
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

</details>

<details>
  <summary>PGAdmin (optional)</summary>

  ## PGAdmin is disabled by default
  Steps to enable PGAdmin:

1. Uncomment everything "pgadmin" related in docker-compose.yml

2. Uncomment "pgadmin" section in configs/proxy/nginx.conf.template

3. Visit https://yourdomain.com/pgadmin/ and login using credentials in .env files ( PGADMIN_DEFAULT_EMAIL and PGADMIN_DEFAULT_PASSWORD )
By default these credentials are:
- Username: edumeet@edu.meet
- Password: edumeet
  
</details>

<details>
  <summary>Authentication (optional)</summary>

  ## Initial setup after first run

Supported types: OIDC, SAML, Local DB (KeyCloak)

*  Authentication is optional but if you want to enable it, you should remove defualtroom paremeters from the config.json at configs/server/ and follow these steps:

1. visit https://yourdomain.com/kc/ and set up your keycloak instance
By default there is a dev configuration according to https://github.com/edumeet/edumeet-management-server/wiki/Keycloak-setup-(OAuth-openid-connect)

By default there is one test user in dev realm :
- Username: edumeet
- Password: edumeet

2. visit https://yourdomain.com/mgmt-admin/ and set up your management server config
   - Create a tenant
   - Create a tenant fqdn / domain
   - Add authentication by using the Well Known URL "https://yourdomain.com/kc/realms/ < yourrealm > /.well-known/openid-configuration" and pressing "Update Parameters from URL" or manually as follow: 
 # ![auth](/images/mgmt-client-setup-1.png)

   *  Secret is located in keycloak admin console/ < yourrealm > / clients / < yourclient > / credentials
   *  Secret is not generated for default dev.json. Regenerate it in keycloak admin console/ < yourrealm > / clients / < yourclient > / credentials and copy it.
    
3. Logout 
4. Visit your domain (Login)
5. Visit https://yourdomain.com/mgmt-admin/ and as the logged in user create a room ( You will be assigned as a room owner and gain all permissions after login, but you can also set permissions for other users too. )
6. Join the room

- For auth you can use any OpenID compatible backend. Keycloak is reccomended for testing, integrating with common third party auth sources and deployments without a central authentication (local users).
- For federated login with discovery we reccommend using SATOSA.
- For SATOSA the mgmt service client_secret_basic auth has to be added to oauth tenant auth methods:

"dynamic": [ "key", "secret", "authorize_url", "access_url", "profile_url", "scope_delimiter", "scope", "redirect_uri" ], "token_endpoint_auth_method": "client_secret_basic" } 

In SATOSA redirect uri should be: https://yourdomain.com/mgmt/oauth/tenant/callback
  
</details>


<details>
  <summary>Firewall ports and recommendations</summary>

  ## Default ports for firewall setting
| Port | protocol | description | network | path | firewall advice | 
| ---- | ----------- | ----------- | ----------- | ----------- |--------------|
|  80 | tcp | edumeet-client webserver (redirect to 443) | host network | / | |
|  443 | tcp | edumeet-client https webserver and signaling proxy | host network |  / | |
|  3000 |  | edumeet-media-node port | host network | - | should be limited so only the room-server can access it |
|  3479 |  | coturn port | host network | - | |
|  40000-40249 | tcp/udp | edumeet-media-node ports | host network | - | |

 # ![Network](/images/edumeet_netw.png)

  
</details>




<details>
  <summary>Development</summary>

eduMEET development usualy happens in 2 ways:
- Running components manualy
- Running edumeet-docker with components linked into the docker container or passed to the proxy.

*Without valid certs you have to allow localhost/local ip to work without certs in the browser.

# ![Dev](/images/edumeet_dev.png)

</details>





## Docker networking
edumeet-media-node container works in "host" network mode, because bridge mode has the following issue: ["Docker hangs when attempting to bind a large number of ports"](https://success.docker.com/article/docker-compose-and-docker-run-hang-when-binding-a-large-port-range)

## FAQ
Q: I get "Cannot find module erros" regarding config files

A: You are probably having a relative path issue with docker check if you are in the correct directory. (edumeet-docker folder)
_________________

Q: Docker-compose started, but some components are restarting.

A: You are probably having a config or permission problem. Try starting with "docker compose" without the detach parameter to see logs.


Or alternatively with:


```docker logs -f <edumeet_container_name>```

In the .env file there are a few log variables:

SERVER_DEBUG=

MGMT_DEBUG=

MGMT_CLIENT_DEBUG=

MN_DEBUG=

Changing them to * will provide extended logs that can help  debugging problems.
_________________

Q: KeyCloak won't start

A: KeyCloak is sensitive to permission settings on cert files. Please check 
_________________

Q: I get network conflicts with docker

A: You will most likely running an old version of docker, that doesn't handle links between containers
_________________

Q: I get network problems with room-server and media node  within docker when using ufw

A: ufw by default blocks incoming traffic, and  thinks that media control port is accessed outside of the network.
Firewall can also cause issues with component internal communication.



