# NamelessMC Docker [![](https://images.microbadger.com/badges/image/birkhofflee/namelessmc-docker.svg)](https://microbadger.com/images/birkhofflee/namelessmc-docker)
This is the official Docker image for NamelessMC. Deploy with ease!

# Usage

## Install Docker
Obviously, if you wanna use Docker for deployment, you need to install Docker.

You have to manually install Docker first if you don't have it installed on your server. Check out the official install guide here: https://docs.docker.com/engine/installation.

If you want to specify the version of NamelessMC you want, head to https://github.com/BirkhoffLee/NamelessMC-docker#manually-run-commands.

## Automated deployment
You will need to install `docker-compose` for automated deploying. If you don't have it installed, run the following:
```
$ curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ chmod +x /usr/local/bin/docker-compose
```

> Note: If you get a “Permission denied” error while running the commands above, please add `sudo` at the start of them and run again. This will require sudo access.

When you're done, clone this repository and run! (`-d` means detach mode, e.g. run in background)
```
$ git clone https://github.com/BirkhoffLee/NamelessMC-docker
$ cd NamelessMC-docker
$ docker-compose up -d
```

By default, the NamelessMC will then running on `0.0.0.0:80`! Open `http://<your-server-ip-address>` on your browser. Instead, if you're trying on your personal computer, open `http://localhost` then.

## Manually run commands
If you more like to run the containers by yourself or using them with other containers like [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy), you may want to do it yourself.

First, clone the repository:

```
$ git clone https://github.com/NamelessMC/Nameless-Docker
$ cd Nameless-Docker
```

Next, build the image.

```
$ docker build -t namelessmc .
```

If you want to specify the version:

```
$ docker build --build-arg NAMELESSMC_VERSION=1.0.16 -t namelessmc .
```

The version number **MUST BE** listed [here](https://github.com/NamelessMC/Nameless/releases) and it's **not guranteed** to work.

Next, run the image we just built and a MySQL container as well.

```bash
$ docker run -d -e "MYSQL_ROOT_PASSWORD=nameless" -e "MYSQL_USER=nameless" -e "MYSQL_PASSWORD=nameless" -e "MYSQL_DATABASE=nameless" --name nameless_db mysql
$ docker run -d -p 80:80 --link nameless_db --name nameless namelessmc
```

That's it!

# NamelessMC Installation
After deploying the containers, open up the corresponding URL in your web browser to get started with NamelessMC.

By default, the web server will be available at `0.0.0.0:80`, means if you deployed it on you own computer, the URL is gonna be `http://localhost`. Instead, if you did it on a remote server, the URL would be `http://<your-server-ip-addr>`.

Follow the install instructions. When the database configuration page shows up, fill in `nameless_db` for the *database address*. For database username, password and database name, fill `nameless` for all of them.

When you're done, submit and follow the rest of installation.

# About
This repository was moved from [Birkhoff Lee](https://github.com/BirkhoffLee), and the original repository is here: https://github.com/BirkhoffLee/namelessmc-docker, carefully made in Taiwan. :heart: