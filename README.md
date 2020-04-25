# cod2docker

Fork of lonsofore/cod2 - COD2 1.0 using voron00's libcod. Based on Ubuntu Focal (20.04)

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
    stdin_open: true
    tty: true
    network_mode: host
    volumes:
      - /opt/cod2/main:/cod2/main
      - /opt/cod2/main/games_mp.log:/cod2/.callofduty2/main/games_mp.log
    environment:
     PARAMS: "+set fs_homepath /cod2/.callofduty2 +set dedicated 2 +set net_port 28960 +set sv_cracked 1 +exec server.cfg"
     CHECK_PORT: 28960
```
And replace paths & environment parameters accordingly.


# Support

You always can get support on [Killtube thread](https://killtube.org/showthread.php?3167-CoD2-Setup-CoD2-with-Docker) and [Killtube Discord chat](https://discordapp.com/invite/mqBchQZ). 
