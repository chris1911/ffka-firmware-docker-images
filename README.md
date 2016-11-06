# ffka-firmware-autobuild
Dockerfile and supplements to create ffka-firmware images for different architectures.  
Please have a look at the Dockerfile to see for which combination the firmware is built.  

These instructions are for people who want to build their own firmware image or want to understand how Docker can be used as a build server.
If you just want to get the latest ffka firmware, you'll better be off [here](http://ffka.net/firmware.html).

The intent for this Dockerfile is to build the firmware images in an isolated environment and keep the host clean of build tools.
This is quite simple with Docker:

```prerequisite: docker (package may be called docker, docker.io, lxc-docker, ...)```

Modify the Dockerfile:

* Choose versions:
	* GLUON_BRANCH - e.g.v2016.2, see [gluon releases](https://github.com/freifunk-gluon/gluon/releases)
	* SITE_BRANCH - e.g. v0.2.90-stable.1, see [ffka-site releases](https://github.com/ffka/site-ffka/releases) - please stick with stable versions
* Choose targets:
Commenting out the 3-liner for each unwanted target will speed up compilation time.

    RUN     export GLUON_TARGET=ar71xx-generic && \

		        verbosemake -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET}

	        	verbosemake -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}
	
Let Docker build the image for you. This may take some (or lots of) time.

```docker.io build -t <tag name> <path to dir containing Dockerfile>```

Create a container based on the image:

```docker run -ti <tag name> /bin/bash```

You now have a shell started inside the container. You already know the path to the gluon installation:

```cd  /gluon/<GLUON_TARGET>```

To get rolling (firmware building), please have a look at the essential build commands in the Dockerfile.

Happy firmware building!
