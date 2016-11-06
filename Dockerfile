FROM debian:jessie

MAINTAINER chris1911@users.noreply.github.com

#
# This Dockerfile is intended for custom builds on local machines.
# Dockerhub will probably not be able to compile this image.
# The resulting image size may exceed 10GiB per target. This Dockerfile includes 9 targets at the moment.
#
# Adopt SITE and SITE_BRANCH to your own site.cfg
# Adjust GLUON_BRANCH to your desired architecture.
# The different architectures are hard-coded in this file.
#

# An excerpt of available architectures as of 2016-11-06 are:
# v2015.1:	ar71xx-{generic,nand}; mpc85xx-generic; x86-{kvm_guest,generic}
# v2016.2:	ar71xx-generic  ar71xx-nand  brcm2708-bcm2708  brcm2708-bcm2709  mpc85xx-generic  x86-64  x86-generic  x86-kvm_guest  x86-xen_domu
# See https://github.com/freifunk-gluon/gluon/blob/master/targets/targets.mk for a list of supported architectures

ENV GLUON https://github.com/freifunk-gluon/gluon.git
ENV GLUON_BRANCH v2016.2

ENV SITE https://github.com/ffka/site-ffka.git
ENV SITE_BRANCH master

ENV BASEDIR /gluon
ENV BUILDDIR /gluon/build
ENV DEBIAN_FRONTEND noninteractive

RUN	\
	echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Recommends "0";' && \
	echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Suggests "0";' && \
	apt-get -y update && \
	apt-get -y install bsdmainutils build-essential ca-certificates cmake file flex \
			   gawk gettext git less liblzma-dev liblzma5 libncurses5-dev libssl-dev \
			   p7zip-full pkg-config python subversion sudo unzip vim wget zlib1g-dev

RUN	\
	useradd -m gluonbuilder -s /bin/bash && \
	mkdir -p ${BUILDDIR} && \
	chown gluonbuilder:gluonbuilder -R ${BASEDIR} && \
	echo 'gluonbuilder  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers


# openwrt: use unprivileged user to build sources (or fail if root)
USER gluonbuilder
ENV HOME /home/gluonbuilder

RUN	cd ${BUILDDIR} && \
	git config --global user.email "youremail@address.here" && \
	git config --global user.name "Your name here"

RUN	cd ${BUILDDIR} && \
	git clone -b ${GLUON_BRANCH} ${GLUON} ${BUILDDIR} && \
	git clone -b ${SITE_BRANCH}  ${SITE}  ${BUILDDIR}/site && \
	\
	export NPROC=$(nproc) && \
	make -C ${BUILDDIR} update

RUN	export GLUON_TARGET=ar71xx-generic && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}
	
RUN	export GLUON_TARGET=ar71xx-nand && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	export GLUON_TARGET=brcm2708-bcm2708 && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	export GLUON_TARGET=brcm2708-bcm2709 && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	export GLUON_TARGET=mpc85xx-generic && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	export GLUON_TARGET=x86-64 && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	export GLUON_TARGET=x86-generic && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	export GLUON_TARGET=x86-kvm_guest && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	export GLUON_TARGET=x86-xen_domu && \
	make -C ${BUILDDIR} clean GLUON_TARGET=${GLUON_TARGET} && \
	make -C ${BUILDDIR} -j $NPROC GLUON_TARGET=${GLUON_TARGET}

RUN	cd ${BUILDDIR}/output/images/factory    && md5sum -b * > md5.txt && \
	cd ${BUILDDIR}/output/images/sysupgrade && md5sum -b * > md5.txt && \
	make -C ${BUILDDIR} manifest GLUON_BRANCH=stable && \
	7z a -t7z -mx=9 -ms=on ${BASEDIR}/images-${GLUON_BRANCH}-${GLUON_TARGET}.7z ${BUILDDIR}/output/images/

# The compiled images and the yet to be signed manifest can be found in ${BUILDDIR}/images/
CMD /bin/bash
