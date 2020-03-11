FROM registry.redhat.io/ubi8/ubi-minimal
USER root
ARG USER=marc
ARG S2IDIR="/var/tmp"
ARG APPDIR="/var/tmp"

LABEL maintainer="marcredhat" \
      io.k8s.description="UBI-8 / Gradle S2I builder for Java Applications." \
      io.k8s.display-name="Handy Environment" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,maven,gradle" \
      io.openshift.s2i.scripts-url="image://$S2IDIR/bin" 
      #io.openshift.s2i.assemble-user="marc"
RUN microdnf install shadow-utils findutils
COPY s2i $S2IDIR
RUN useradd $USER 
RUN chmod 777 -R $S2IDIR && chmod 777 -R /var/tmp/
RUN chown -R $USER /var/tmp
RUN chown -R $USER $S2IDIR

RUN chown -R $USER $APPDIR && chmod 777 -R $APPDIR


RUN microdnf -y update 

RUN microdnf  install maven -y && \
    microdnf  install -y unzip && \
    microdnf  install -y wget && \
    wget https://services.gradle.org/distributions/gradle-6.2.2-bin.zip && \
    mkdir /opt/gradle && \
    unzip -d /opt/gradle gradle-6.2.2-bin.zip && \
    ls /opt/gradle/gradle-6.2.2


RUN microdnf clean all
ENV PATH=$PATH:/opt/gradle/gradle-6.2.2/bin

#ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot


WORKDIR $APPDIR

EXPOSE 8080

RUN chown -R 1001:0 $S2IDIR && \
    chmod -R g+rw $S2IDIR && \
    chmod -R g+rx $S2IDIR

# switch to the user 1001
USER 1001

#CMD ["$S2IDIR/bin/run"]
