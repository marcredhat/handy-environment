FROM registry.redhat.io/ubi8/ubi-minimal
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
      io.openshift.s2i.assemble-user="root"

COPY s2i $S2IDIR
RUN useradd $USER 
RUN chmod 777 -R $S2IDIR && chmod 777 -R /tmp/
RUN chown -R $USER /tmp
RUN chown -R $USER $S2IDIR

RUN chown -R $USER $APPDIR && chmod 777 -R $APPDIR


RUN dnf -y update 

RUN dnf install maven -y && \
    dnf install -y unzip && \
    dnf install -y wget && \
    wget https://services.gradle.org/distributions/gradle-6.2.2-bin.zip && \
    mkdir /opt/gradle && \
    unzip -d /opt/gradle gradle-6.2.2-bin.zip && \
    ls /opt/gradle/gradle-6.2.2

ENV PATH=$PATH:/opt/gradle/gradle-6.2.2/bin


WORKDIR $APPDIR

EXPOSE 8080

USER $USER

#CMD ["$S2IDIR/bin/run"]
