# ffka-firmware-autobuild
Dockerfile and supplements to create ffka-firmware images for different architectures.  
There are different branches which address the various targets (architectures) and gluon branches (stable: 2014.4, unstable: master).
Please have a look at the Dockerfile to see for which combination the firmware is built.  
The naming of the branch may also provide some hints: 2014.4-mpc85xx-generic uses gluon-branch '2014.4' and targets 'mpc85xx-generic'.  
At the moment, master will also build firmware for ar71xx-generic of gluon-branch 2014.4 as branch '2014.4-ar71xx-generic' does as well.

These instructions are for people who want to build their own firmware image or want to understand how Docker can be used as a build server.
If you just want to get the latest ffka firmware, you'll be better off [here](http://ffka.net/firmware.html).

There are two ways to use this repository:

1. Get ready-built firmware images (don't care about build environment, configs and such stuff)
2. Use the Dockerfile to build images on your own (and try out some fancy settings)

Here are more detailled instructions:

1. Getting the ready-built firmware images out of a Docker image is not as easy as it ought to be.
	Maybe abusing Docker as a build server is not what Docker is made for --- but it works quite well.
	Okay, let's get back to work. This github repository is linked to a [docker repository with the same name](https://registry.hub.docker.com/u/ffka/ffka-firmware-autobuild/).
	Cloning the docker repository is easy:

	``` docker pull ffka/ffka-firmware-autobuild ```

	You'll end up downloading a bunch of binaries (docker layers) which all are part of the docker image 'ffka/ffka-firmware-autobuild'.
	The freifunk karlsruhe firmware images can be found *inside* the image in

	```/gluon/images-${SITENAME}-${BRANCH}-${GLUON_TARGET}.7z (e.g. /gluon/images-ffka-2014.4.x-ar71xx-generic.7z)```

	In order to extract the file from the image, you have to create a container in the first place:

	```docker run --name ffka-2014.4.x-ar71xx ffka/ffka-firmware-autobuild /bin/true```

	The command supplied to the container (/bin/true) will stop the container at once. You can also create a shell inside the container and look around (remind the params -t -i).
	Now that we have a container, we can easily copy the firmware images out of it:

	```docker cp /gluon/images-ffka-2014.4.x-ar71xx-generic.7z <local dir>```

	After that, we can free up some space and get rid of both the container and the image:

	```docker rm ffka-2014.4.x-ar71xx && docker rmi ffka/ffka-firmware-autobuild```

	Have fun with the firmware but be aware that the firmware is **not yet signed off** by anyone.

2. Creating a build environment and customizing images is quite simple with Docker.

	```prerequisite: docker (package may be called docker, docker.io, lxc-docker, ...)```

	Checkout the [github repository](https://github.com/ffka/ffka-firmware-autobuild.git): 

	```git clone https://github.com/ffka/ffka-firmware-autobuild.git```

	Modify the Dockerfile:
	* Comment out the build and cleanup steps, e.g. everything after the block:

		```RUN \```

		```make -C /gluon/${GLUON_TARGET} update```

	* Do not forget to comment out/remove the '&& \' at the end of the line mentioned above!!

	Let Docker build the image for you. This may take some time. Building on the Docker hub for example lasts more than 2 hours.

	```docker.io build -t <tag name> <path to dir containing Dockerfile>```

	Create a container based on the image:

	```docker run -ti <tag name> /bin/bash```

	You now have a shell started inside the container. You already know the path to the gluon installation:

	```cd  /gluon/<GLUON_TARGET>```

	To get rolling (firmware building), please have a look at the essential build commands in the Dockerfile.

	Happy firmware building!
