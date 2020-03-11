FROM registry.redhat.io/ubi8/ubi
ARG USER=marc
ARG S2IDIR="/home/s2i"
ARG APPDIR="./"

LABEL maintainer="marcredhat" \
      io.k8s.description="S2I builder for Java Applications." \
      io.k8s.display-name="Handy Environment" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,maven,gradle" \
      io.openshift.s2i.scripts-url="image://$S2IDIR/bin"

COPY s2i $S2IDIR
RUN chmod 777 -R $S2IDIR

RUN useradd $USER \
    && chown $USER:$USER $APPDIR \
    && groupadd $USER $USER \
    && chmod 777 -R $APPDIR

RUN dnf -y update -y 

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

CMD ["$S2IDIR/bin/run"]
