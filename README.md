# platform
============================

Package all the repos of quote.academy's api.

## DOCKER

### Requirements

* [docker](https://docs.docker.com/installation/)
* [docker-composer](https://docs.docker.com/compose/install/)
* make

#### Requirements on Mac OS X

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [homebrew](http://brew.sh/)

* Install docker & docker machine
```shell
$ brew install docker docker-machine
```

Install docker-compose *switch version from 1.8.1 to the latest one*
```shell
curl -L https://github.com/docker/compose/releases/download/1.8.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compos
```

* Create a machine
```shell
$ docker-machine create --driver virtualbox default
```

* List available machines again to see your newly minted machine.
```shell
$ docker-machine ls
```

* Get the environment commands for your new VM
```shell
$ docker-machine env default
```

* Connect your shell to the new machine.
```shell
$ eval "$(docker-machine env default)"
```

*Set this env vars to your **.bashrc** or **.zshrc** file*
```
echo '\neval "$(docker-machine env default)"' >> ~/.zshrc
```
```
source ~/.zshrc
```

## PLATFORM

### Edit your hosts file

Open the hosts file:

```shell
$ sudo vi /etc/hosts
```

Add these lines:

```shell
127.0.0.1 api.quote.dev
```

##### For *Mac OS X* users, use the IP given by this command instead of 127.0.0.1 :
```shell
docker-machine ip
```

### Initialize the project

Run this command to initialize the project :

```bash
make all INIT_FILE=true WITHOUT_CACHE=true
```

### Reload the matrix

```bash
docker-compose down
bin/docker-cleanup.sh
make matrix-reload INIT_FILE=true
```
