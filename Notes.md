#starts up docker daemon
$ sudo service docker restart
$ sudo service docker start
$ sudo service docker stop


#runs interative bash within docker container
docker run -i -t ubuntu:14.04 /bin/bash 
-i => interrative shell
-t => tty

#send running container in background
CTRL + P + Q

#runs image in background (detached)
$docker run -d centos:7 ping 127.0.0.1 -c 50

#running containers
$docker ps

#shows all containers - running or not
$docker ps -a


#DOCKER LOGS
$docker logs [short id] (first column in docker ps)

#tail logs
$docker logs -f 1173fcfe677e

#maps ports container has exposed to ports on host
$docker run -d -P tomcat:7
-detached 

#ADD THINGS TO CONTAINER
docker run -it ubuntu:14.04 bash
--apt-get install curl //installs curl onto image
$docker commit 189d398deb4c anthonygaro/myubuntuapp:1.0 //save as new image with curl in it
verify with docker images
then log back in { docker run -it anthonygaro/myubuntuapp:1.0 bash }
-verify with 'which curl'

### DOCKER FILE -> Aggregate commands to eliminate intermediate docker commits
FROM ubuntu:14.04 //which base image
RUN apt-get install nano //commands to RUN
RUN apt-get install curl 
########

#BUILD
docker build [options] [path] //[path] is build context
#Flags
-f -> find docker file
-t -> tag image
$docker build -t [repository:tag] [path]

#CMD
-defines default command to execute when container is CREATED
-performs no action during build
-can ONLY be specified in Dockerfile
-can be OVERRIDEN at RUNTIME -> docker run anthonygaro/testimage:1.1 echo "Saluton Mondo"
-Formats:
	#shell
	CMD ping 127.0.0.1 -c 30
	#Exec
	CMD ["ping","127.0.0.1","-c","30"] //json array

#ENTRYPOINT
-defines the command that will run when a cotainer is executed
-runtime args and CMD instruction are passed as params to the ENTRYPOINT instruction
-Shell and Exec form
-EXEC preferable. Shell form cannot accept args at runtime
-container essentially becomes executable
-CANNOT be overriden
ENTRYPOINT ["ping"] //Dockerfile entry
--build image
$docker run anthonygaro/testimage:1.2 127.0.0.1 -c 5

#TERMINAL Access
#EXEC
-exec command starts up another process in container
-execute /bin/bash to get a bash shell
$docker exec -i -t [container ID] /bin/bash
-exiting the terminal will NOT terminate container

#DELETE
-can only delete containers that have been stopped
$docker rm [container id]

#DELETE LOCALLY
$docker rmi [image ID]
$docker rmi [repo:tag]
-if image is tagged multiple times, remove each tag

#PUSH
$docker push [repo:tag]
-local repo must have same name and tag as the Docker Hub repo

#TAGGING
-used to rename a local image before pushing to docker hub - useful when remote and local repos have different names
$docker tag [image ID] [repo: tag]
$docker tag [local repo: tag] [Docker Hub repo: tag]

#VOLUME
-mounted when creating or executing a container
-can be mapped to a host dir
-volume paths must be specified

Examples:
Execute a new container and mount the folder /myvolume into its file system at the root level
$docker run -d -P -v /myvolume nginx:1.7
Execute a new container and map the /data/src folder from host into /test/src folder in the container //hostDir:containerDir
docker run -i -t -v /data/src:/test/src nginx:1.7

#VOLUME - Dockerfile
-VOLUME instruction creates mount point
-can specify args - JSON array of string
-CANNOT map volumes to host directories
-Volumes are initilized when the container is executed
String example
-VOLUME /myvol
String example with multiple volumes
-VOLUME /www/website1.com /www/website2.com
JSON example
-VOLUMN ["myvol","myvol2"]

docker run -d -P -v /www/website nginx -> mounts volumne in container. Can make file changes and commit but files will not be persisted

#PORTS
$docker run -d -p 8080:80 nginx:1.8 //hostPort:container:Port
##AUTOMATIC PORT MAPPING
-P flag
-host port numbers used range: 49153->65535
-only works for ports defined in EXPOSE instruction

#EXPOSE
-configures which ports a container will listen on at runtime
-Ports still need to be mapped when container is executed
EXPOSE 80 443

#LINKING
-link containers WITHOUT exposing network ports. Links established based on container names
-2 containers -> Recepient & Source
--Recepient has access to data on source containers
Process:
1) Create source container FIRST
$docker run -d --name database postgres
2) Create recepient container and use the --link option
docker run -d  -P --name website --link database:db nginx //db=alias
example: $ docker run -it --name website --link dbms:db ubuntu:14.04 bash
VERIFY:
root@6de5382c5c6a:/# cat /etc/hosts
.....
172.17.0.3	db 533b7ca0876f dbms
MORE VERIFICATION: IPAddress below matches above
hierro@hierro-desktop:~/dockerTest$ docker inspect dbms | grep IPAddress
        "SecondaryIPAddresses": null,
        "IPAddress": "172.17.0.3",
                "IPAddress": "172.17.0.3",

#LOGS
$ docker logs -f --tail 1 small_yonath //show only last line in log file
-to view individual app logs. Map host directory to container log directory
$ docker run -d -P -v /nginxlogs:/var/log/nginx nginx
EXAMPLE:
hierro@hierro-desktop:~/dockerJavaHelloWorld$ docker run -d -P -v /container/logs/nginx:/var/log/nginx nginx
bad60bbc8e3a7a4f85dce67778125e34f9e4b3a239efa3691288d5ccb3635d5e
hierro@hierro-desktop:~/dockerJavaHelloWorld$ cd /container/logs/nginx/ -> go to mapped directory (in host)
hierro@hierro-desktop:/container/logs/nginx$ ls -> show log files
access.log  error.log
hierro@hierro-desktop:/container/logs/nginx$ tail -f access.log -> tail access log file

#INSPECT
-displays all details about a container in JSON array
-use GREP to find specific property
$ docker inspect [container name]
$ docker inspect [container name] | grep IPAddress
//Grab specific part of inspection json
$ docker inspect --format {{.NetworkSettings.IPAddress}}  small_yonath 
172.17.0.2
"NetworkSettings": {
        "GlobalIPv6PrefixLen": 0,
        "IPAddress": "172.17.0.2",
...
}

#Docker Daemon
##AS A SERVICE
$ sudo service docker stop
$ sudo service docker start
$ sudo service docker restart
##IF NOT RUNNING AS A SERVICE, RUN DOCKER EXECUTABLE IN DAEMON MODE TO START DAEMON
$ sudo docker -d &
##IF NOT RUNNING AS A SERVICE, SEND A SIGTERM TO THE DOCKER PROCESS TO STOP
$ pidof docker //finds Docker process PID
$ sudo kill $(pidof docker)

#Docker Configuration
-located in /etc/default/docker
-use DOCKER_OPTS to control startup options for the daemon when running as SERVICE
-restart services for changes to take effect
$ sudo service docker restart
//Start daemon with log level of debug and allow connections to an insecure registry at the domain of myserver.org
DOCKER_OPTS="--log-level debug --insecure-registry myserver.org:5000"

#Docker Daemon Logging
--log-level: (most verbose to lease)
Debug
Info
Warn
Error
Fatal
$ sudo docker -d --log-level=debug
/etc/default/docker.DOCKER_OPTS="--log-level debug" //logs found in /var/log/upstart/docker.log

#Private Registry
-used in place of Dockerhub behind firewalls for distributing among peers
-Run registry server inside container
-registry image: https://hub.docker.com/r/library/registry/
--image contains pre-configured registry 2.0
$ docker run -d -p 5000:5000 registry:2.0
##Push and Pull
-first tag image with host IP or domain of the registry server, then run $ docker push
//tag image and specify registry host
$ docker tag [image ID] myserver.net:5000/my-app:1.0
//Push image to registry
$ docker push myserver.net:5000/my-app:1.0
//Pull image from registry
$ docker pull myserver.net:5000/my-app:1.0

EXAMPLE
$ docker push localhost:5000/myhello-world:1.0

//VERIFY PUSH
hierro@hierro-desktop:/container/logs/nginx$ curl -v -X GET http://localhost:5000/v2/myhello-world/tags/list
* Hostname was NOT found in DNS cache
*   Trying 127.0.0.1...
* Connected to localhost (127.0.0.1) port 5000 (#0)
> GET /v2/myhello-world/tags/list HTTP/1.1
> User-Agent: curl/7.35.0
> Host: localhost:5000
> Accept: */*
> 
< HTTP/1.1 200 OK
< Content-Type: application/json; charset=utf-8
< Docker-Distribution-Api-Version: registry/2.0
< Date: Mon, 28 Dec 2015 04:34:18 GMT
< Content-Length: 40
< 
{"name":"myhello-world","tags":["1.0"]}
* Connection #0 to host localhost left intact

#Docker-Machine Overview - For Mac and PC - 4c3371bc86ce6992d24b86ee007193033501c45842474cc74b37b5fe33a278b5
-tool that automatically provisions Docker hosts and installs Docker engine on them
-create additional hosts on your computer
-create hosts on cloud services
##Creating Host - Locally
$ docker-machine create --driver virtualbox testhost
##Creating Host - Cloud
$ docker-machine create
	--driver digitalocean \
	--digitalocean-access-token <token> \
	--digitalocean-size 2gb \
	testhost
##List
$ docker-machine ls

#DOCKER SWARM - clusters Docker hosts and schedules containers
-turns a pool of host machines into a a single virtual host
-ships with simple scheduling backend
-supports many discovery backends:	
	Hosted discovery
	etcd
	Consul
	ZooKeeper
	Static files
## HOSTED DISCOVERY
-create cluster on Master  //creates cluster token to be used for connecting with angents
-Start Swarm Master
-Start swarm agent on nodes that have docker installed for clustering
-please note: Agents can be started before or after master
## INSTALLATION
-Most convenient: Docker Swarm Image - https://hub.docker.com/r/library/swarm/
-Swarm containers can be run from image to do the following:
	- Create a cluster
	- Start the Swarm Manager
	- Join nodes to the cluster
	- List nodes on a cluster
$ docker run --rm swarm create //--rm = remove image once it runs (will not show up in Docker ps but will come up in Docker images)
## START SWARM MANAGER
$ docker run -d -P swarm manage token://<cluster token>
$ docker run -d -P swarm manage token://78a7c90e73e3c2b51981a273a0592c89
## SETUP SWARM NODE
/etc/default/docker.DOCKER_OPTS="-H 0.0.0.0:<swarm port>"
$ export DOCKER_HOST-localhost:<swarm port>
## START SWARM NODE
$ docker run -d swarm join
	--addr=<node ip>:<swarm port> \
	token://<cluster token>
## CONNECT DOCKER client to Swarm Manager
-Two methods:
	-change DOCKER_HOST variable to poing to Swarm IP and port
	$ export DOCKER_HOST-127.0.0.1:<swarm port>
	-Run docker with -H and specify the Swarm IP and port
	$ docker -H tcp://127.0.0.1:<swarm port>

##VERIFY
hierro@Dockermaster:~$ docker version
Client:
 Version:      1.9.1
 API version:  1.21
 Go version:   go1.4.2
 Git commit:   a34a1d5
 Built:        Fri Nov 20 13:12:04 UTC 2015
 OS/Arch:      linux/amd64

Server:
 Version:      swarm/1.0.1 ****************************************
 API version:  1.21
 Go version:   go1.5.2
 Git commit:   744e3a3
 Built:
 OS/Arch:      linux/amd64

hierro@Dockermaster:~$ docker info
Containers: 2
Images: 2
Role: primary
Strategy: spread
Filters: health, port, dependency, affinity, constraint
Nodes: 2 ***********************************************************
 Dockernode1: 104.236.3.18:2375
  └ Status: Healthy
  └ Containers: 1
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.019 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-68-generic, operatingsystem=Ubuntu 14.04.3 LTS, storagedriver=aufs
 Dockernode2: 159.203.84.37:2375
  └ Status: Healthy
  └ Containers: 1
  └ Reserved CPUs: 0 / 1
  └ Reserved Memory: 0 B / 1.019 GiB
  └ Labels: executiondriver=native-0.2, kernelversion=3.13.0-68-generic, operatingsystem=Ubuntu 14.04.3 LTS, storagedriver=aufs
CPUs: 2
Total Memory: 2.038 GiB
Name: 46fe7e5fe675

## RUN CLUSTER
$ docker run -d -P nginx
$ docker run -d -P tomcat

-swarm master decides which node to run container on based on scheduling strategy
https://docs.docker.com/swarm/scheduler/strategy/

$ docker ps //will show which node a container is on

hierro@Dockermaster:~$ docker ps
CONTAINER ID        IMAGE     STATUS              PORTS                                                       NAMES
a46decb15771        tomcat    Up About a minute   104.236.3.18:32768->8080/tcp                                Dockernode1/adoring_hypatia
99b52191d8d1        nginx     Up 2 minutes        159.203.84.37:32769->80/tcp, 159.203.84.37:32768->443/tcp   Dockernode2/gloomy_banach

#DOCKER-COMPOSE
-tool for creating and managing multi container applications
-containers are all defined in a single file called 'docker-compose.yml'
-each container runs a particular component/service for your application
	example:
		web frontend
		user authentication
		payments
		database
-container links are defined
-compose will spin up all your containers in a single command
-each service contains instructions for building and running a container
##CONFIGURE COMPOSE .yml file
javaclient:       -------> service
	build: .     								//Path to Dockerfile
	command: java HelloWorld
	links:										//if no alias specified, service name will be used
		- redis									//creates entry in /etc/hosts file
redis:
	image: redis  -------> service				//existing image somewhere
-Each service MUST have build or image declaration

# Delete all containers
docker rm $(docker ps -a -q)
# Delete all images
docker rmi $(docker images -q)
