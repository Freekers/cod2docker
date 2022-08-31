# cod2docker

Fork of lonsofore/cod2 - COD2 1.0 using voron00's libcod.

Very specific image for my personal needs. Pushing it to Docker Hub because 'why not'.

***All credits go to lonsofore***

## How to use

Upload your main folder to your server.

Create (or copy from repo) a docker-compose.yml file containing:
```
version: '3.7'
services:
  cod2:
    image: freekers/docker-cod2_1.0
    container_name: cod2
    restart: always
    network_mode: host
    volumes:
      - /opt/cod2/main:/cod2/main
      - /opt/cod2/main/games_mp.log:/cod2/.callofduty2/main/games_mp.log
    environment:
     PARAMS: "+set fs_homepath /cod2/.callofduty2 +set dedicated 2 +set net_ip 123.123.123.123 +set net_port 28960 +set sv_cracked 1 +exec server.cfg"
     CHECK_PORT: 28960
     CHECK_IP: 123.123.123.123
```
And replace paths & environment parameters accordingly.

## Healthcheck and Server Restarts

There are two types of restarts:

1. If the container would stop for some reason (e.g. ShutdownGame) - Docker will restart it automatically ('restart' part in docker-compose.yml)

1. If for some reason the container would still run, but the `healthcheck` fails (e.g. the CoD2 server process is fronzen), the Docker container will be marked as 'unhealthy'. However, in this case, the container wouldn't be restarted automatically by Docker. For this you need an additional Docker image called `autoheal`. Here's a docker-compose.yml example for autoheal:
```
    version: '3.7'
      services:
        autoheal:
          image: willfarrell/autoheal
          container_name: autoheal
          restart: always
          volumes:
           - /var/run/docker.sock:/var/run/docker.sock
          environment:
           AUTOHEAL_CONTAINER_LABEL: "all"
```
AUTOHEAL_CONTAINER_LABEL with value "all" means that all unhealthy containers would be restarted.

If you change the default server port, i.e. 28960, then make sure the `CHECK_PORT` in your Docker run command or docker-compose matches your `net_port`.

If you change `net_ip`, then make sure the `CHECK_IP` in your Docker run command or docker-compose matches your `net_ip`.

# Support

You always can get support on [Killtube thread](https://killtube.org/showthread.php?3167-CoD2-Setup-CoD2-with-Docker) and [Killtube Discord chat](https://discordapp.com/invite/mqBchQZ). 
