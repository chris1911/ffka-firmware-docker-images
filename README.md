# ffka-firmware-autobuild
Dockerfile and supplements to create ffka-firmware images for different architectures.  
Please have a look at the Dockerfile to see for which combination the firmware is built.  

These instructions are for people who want to build their own firmware image or want to understand how Docker can be used as a build server.
If you just want to get the latest ffka firmware, you'll better be off [here](http://ffka.net/firmware.html).

The intent for this Dockerfile is to build the firmware images in an isolated environment and keep the host clean of build tools.
This is quite simple with Docker:

	prerequisite: docker (package may be called docker, docker.io, lxc-docker, ...)

Modify the Dockerfile:

* Choose versions:
	* GLUON_BRANCH - e.g.v2016.2, see [gluon releases](https://github.com/freifunk-gluon/gluon/releases)
	* SITE_BRANCH - e.g. v0.2.90-stable.1, see [ffka-site releases](https://github.com/ffka/site-ffka/releases) - please stick with stable versions
* Choose targets: Commenting out the following 3-liner for each unwanted target will speed up compilation time.

		RUN     export GLUON_TARGET=<TARGET> && \
		        verbosemake -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	        	verbosemake -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}
	
Let Docker build the image(s) for you. This may take some (or lots of) time.

Compiling during the image creation is quite uncommon for docker, but dockers layer caching mechanism yields great benefits when recompiling.
When recreating the docker image, the previous steps are not performed again; the cached layer is used instead.

	docker build -t <tag name> <path to dir containing Dockerfile>

The firmware images are now within a docker image. Create a container based on the image and add a volume to it. The 'local dir' is mapped to /hostdir in the container.

	docker run -ti -v <local dir>:/hostdir <tag name> /bin/bash

You now have a shell started inside the container and can copy the images and manifest to your host sytem:

	cp  -a /gluon/build/output /hostdir

What's left is signing the manifest and the deployment.

Happy firmware building!
