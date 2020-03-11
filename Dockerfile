# git/Dockerfile
#
# Build a Buildah container image from the latest
# upstream version of Buildah on GitHub.
# https://github.com/containers/buildah
# This image can be used to create a secured container
# that runs safely with privileges within the container.
# The containers created by this image also come with a
# Buildah development environment in /root/buildah.
#
FROM fedora:latest
ENV GOPATH=/root/buildah

# Install the software required to build Buildah.
# Then create a directory and clone from the Buildah
# GitHub repository, make and install Buildah
# to the container.
# Finally remove the buildah directory and a few other packages
# that are needed for building but not running Buildah

RUN dnf -y install --enablerepo=updates-testing \
     make \
     golang \
     bats \
     btrfs-progs-devel \
     device-mapper-devel \
     glib2-devel \
     gpgme-devel \
     libassuan-devel \
     libseccomp-devel \
     git \
     bzip2 \
     go-md2man \
     runc \
     fuse-overlayfs \
     fuse3 \
     containers-common; \
     mkdir /root/buildah; \
     git clone https://github.com/containers/buildah /root/buildah/src/github.com/containers/buildah; \
     cd /root/buildah/src/github.com/containers/buildah; \
     make;\
     make install;\
     rm -rf /root/buildah/*; \
     dnf -y remove bats git golang go-md2man make; \
     dnf clean all;

# Adjust storage.conf to enable Fuse storage.
RUN sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock

# Set up environment variables to note that this is
# not starting with usernamespace and default to 
# isolate the filesystem with chroot.
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot


USER root
ARG USER=marc
ARG S2IDIR="/home/s2i"
ARG APPDIR="/home/s2i"

LABEL maintainer="marcredhat" \
      io.k8s.description="UBI-8 / Gradle S2I builder for Java Applications." \
      io.k8s.display-name="Handy Environment" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,maven,gradle" \
      io.openshift.s2i.scripts-url="image://$S2IDIR/bin" \
      io.openshift.s2i.assemble-user="marc"

COPY s2i $S2IDIR
RUN useradd $USER 
RUN chmod 777 -R $S2IDIR && chmod 777 -R /tmp/
#RUN chown -R $USER /tmp
RUN chown -R $USER $S2IDIR

RUN chown -R $USER $APPDIR && chmod 777 -R $APPDIR


RUN dnf -y update 

RUN dnf  install maven -y && \
    dnf  install -y unzip && \
    dnf  install -y wget && \
    wget https://services.gradle.org/distributions/gradle-6.2.2-bin.zip && \
    mkdir /opt/gradle && \
    unzip -d /opt/gradle gradle-6.2.2-bin.zip && \
    ls /opt/gradle/gradle-6.2.2

ENV PATH=$PATH:/opt/gradle/gradle-6.2.2/bin

ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot


WORKDIR $APPDIR

EXPOSE 8080

USER $USER

#CMD ["$S2IDIR/bin/run"]
