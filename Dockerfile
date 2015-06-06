FROM debian:wheezy

MAINTAINER chris1911@users.noreply.github.com

#
# This Dockerfile is intended for custom builds on local machines.
# Dockerhub will probably not be able to compile this image.
#

#
# Adopt SITE and SITE_BRANCH to your own site.cfg
# Adjust GLUON_BRANCH to your desired architecture.
# The different architectures are hard-coded in this file.
#

# An excerpt of available architectures as of 2015-06-05 are:
# v2014.4:	ar71xx-generic; mpc85xx-generic
# v2015.1:	ar71xx-{generic,nand}; mpc85xx-generic; x86-{kvm_guest,generic}
# See https://github.com/freifunk-gluon/gluon/blob/master/targets/targets.mk for a list of supported architectures

ENV GLUON https://github.com/freifunk-gluon/gluon.git
ENV GLUON_BRANCH v2014.4
# ENV GLUON_BRANCH v2015.1

ENV SITE https://github.com/ffka/site-ffka.git
ENV SITE_BRANCH master

ENV BASEDIR /gluon
ENV BUILDDIR /gluon/build

RUN	\
	echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Recommends "0";' && \
	echo >> /etc/apt/apt.conf.d/00aptitude 'APT::Install-Suggests "0";' && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get -y update && \
	apt-get -y install bsdmainutils build-essential ca-certificates cmake file \
			   flex gawk gettext git less liblzma-dev liblzma5 libncurses5-dev \
			   p7zip-full pkg-config python subversion sudo unzip vim wget zlib1g-dev

RUN	\
	useradd -m gluonbuilder -s /bin/bash && \
	mkdir -p ${BUILDDIR} && \
	chown gluonbuilder:gluonbuilder -R ${BASEDIR} && \
	echo 'gluonbuilder  ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers


# some build and cleanup helper
ADD helper /gluon/helper

# openwrt: use unprivileged user to build sources (or fail if root)
USER gluonbuilder
ENV HOME /home/gluonbuilder

RUN \
	cd ${BUILDDIR} && \
	git config --global user.email "youremail@address.here" && \
	git config --global user.name "Your name here"

RUN \
	export GLUON_TARGET=ar71xx-generic && \
	cd ${BUILDDIR} && \
	git clone -b ${GLUON_BRANCH} ${GLUON} ${BUILDDIR} && \
	git clone -b ${SITE_BRANCH} ${SITE} ${BUILDDIR}/site && \
	\
	. /gluon/helper && \
	export NPROC=$(nproc) && \
	verbosemake -C ${BUILDDIR} -j ${NPROC} update && \
	verbosemake -C ${BUILDDIR} -j 1 download && \
	verbosemake -C ${BUILDDIR} -j 1 prepare-target && \
	verbosemake -C ${BUILDDIR} -j ${NPROC} prepare && \
	verbosemake -C ${BUILDDIR} -j ${NPROC} images && \
	\
	cd ${BUILDDIR}/images/factory && md5sum -b * > md5.txt && \
	cd ${BUILDDIR}/images/sysupgrade && md5sum -b * > md5.txt && \
	verbosemake -C ${BUILDDIR} manifest GLUON_BRANCH=stable && \
	\
	7z a -t7z -mx=9 -ms=on ${BASEDIR}/images-${GLUON_BRANCH}-${GLUON_TARGET}.7z ${BUILDDIR}/images/ && \

#RUN \
#	export GLUON_TARGET=ar71xx-nand && \
#	cd ${BUILDDIR} && \
#	git clone -b ${GLUON_BRANCH} ${GLUON} ${BUILDDIR} && \
#	git clone -b ${SITE_BRANCH} ${SITE} ${BUILDDIR}/site && \
#	\
#	. /gluon/helper && \
#	export NPROC=$(nproc) && \
#	verbosemake -C ${BUILDDIR} -j ${NPROC} update && \
#	verbosemake -C ${BUILDDIR} -j 1 download && \
#	verbosemake -C ${BUILDDIR} -j 1 prepare-target && \
#	verbosemake -C ${BUILDDIR} -j ${NPROC} prepare && \
#	verbosemake -C ${BUILDDIR} -j ${NPROC} images && \
#	\
#	cd ${BUILDDIR}/images/factory && md5sum -b * > md5.txt && \
#	cd ${BUILDDIR}/images/sysupgrade && md5sum -b * > md5.txt && \
#	verbosemake -C ${BUILDDIR} manifest GLUON_BRANCH=stable && \
#	\
#	7z a -t7z -mx=9 -ms=on ${BASEDIR}/images-${GLUON_BRANCH}-${GLUON_TARGET}.7z ${BUILDDIR}/images/ && \
#

# This container does not offer any services
CMD /bin/bash
