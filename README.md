

![Docker Pulls](https://img.shields.io/docker/pulls/nerodon/icarus-dedicated)
![Docker Stars](https://img.shields.io/docker/stars/nerodon/icarus-dedicated)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/nerodon/icarus-dedicated/latest)
![GitLab (self-managed)](https://img.shields.io/gitlab/license/fred-beauch/icarus-dedicated-server)



For assistance, message **@Nerodon** on the official Icarus Discord or open an issue on Gitlab

[<img src="https://img.shields.io/badge/Discord-Linux_Docker_Support-7289da?logo=discord&logoColor=white">](https://gitlab.com/fred-beauch/icarus-dedicated-server)
[<img src="https://img.shields.io/badge/Repository-Gitlab-orange?logo=gitlab">](https://gitlab.com/fred-beauch/icarus-dedicated-server)



# icarus-dedicated-server
This dedicated server will automatically download/update to the latest available server version when started. The dedicated server runs in Ubuntu 22.04 and wine

## Environment Vars
- SERVERNAME : The name of the server on the server browser (You must specify this, the SessionName in the ServerSettings.ini file is always ignored)
- PORT : The game port (not specifying it will default to 17777)
- QUERYPORT : The query port (not specifying it will default to 27015)
- STEAM_USERID : Linux User ID used by the steam user and volumes (not specifying it will default to 1000)
- STEAM_GROUPID: Linux Group ID used by the steam user and volumes (not specifying it will default to 1000)
- STEAM_ASYNC_TIMEOUT: Sets the Async timeout to this value in the Engine.ini on server start (not specifying it will default to 60)
- BRANCH: Version branch (public or experimental, not specifying it will default to public)


## Ports
The server requires 2 UDP Ports, the game port (Default 17777) and the query port (Default 27015)
They can be changed by specifying the PORT and QUERYPORT env vars respectively.

## Volumes
- The server binaries are stored at /game/icarus
- The server saves are stored at /home/steam/.wine/drive_c/icarus

**Note:** by default, the volumes are owned by user 1000:1000 please set the permissions to the volumes accordingly. To change the user and group ID, simply define the STEAM_USERID and STEAM_GROUPID environment variables.

## Example Docker Run
```bash
docker run -p 17777:17777/udp -p 27015:27015/udp -v data:/home/steam/.wine/drive_c/icarus -v game:/game/icarus -e SERVERNAME=AmazingServer nerodon/icarus-dedicated:latest
```
## Example Docker Compose
```yaml
version: "3.8"

services:
 
  icarus:
    container_name: icarus-dedicated
    image: nerodon/icarus-dedicated:latest
    hostname: icarus-dedicated
    init: true
    restart: "unless-stopped"
    networks:
      host:
    ports:
      - 17777:17777/udp
      - 27015:27015/udp
    volumes:
      - data:/home/steam/.wine/drive_c/icarus
      - game:/game/icarus
    environment:
      - SERVERNAME=AmazingServer
      - BRANCH=public
      - PORT=17777
      - QUERYPORT=27015
      - STEAM_USERID=1000
      - STEAM_GROUPID=1000
      - STEAM_ASYNC_TIMEOUT=60

volumes:
  data: {}
  game: {}
 
networks:
  host: {}
```

## License
MIT License

## Known Issues

* Out of memory error: `Freeing x bytes from backup pool to handle out of memory`
  and `Fatal error: [File: Unknown] [Line: 197] \nRan out of memory allocating 0 bytes with alignment 0\n` but system
  has enough memory.
  * **Solution:** Increase maximum number of memory map areas (vm.max_map_count) tested with `262144`<br/>
    **temporary:**
    ```bash
      sysctl -w vm.max_map_count=262144
    ```
    **permanent:**
    ```bash
      echo "vm.max_map_count=262144" >> /etc/sysctl.conf && sysctl -p
    ```
  **Credit:** Thanks to Icarus discord user **Fabiryn** for the solution.