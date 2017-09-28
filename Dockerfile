FROM ubuntu:16.04
LABEL "author"="Hasan Comak"

ENV GERRIT_VERSION="2.13.9"
ENV GERRIT_RELEASE=1

ENV GERRIT_HOME /var/gerrit
ENV GERRIT_SITE ${GERRIT_HOME}/review_site
ENV GERRIT_USER gerrit
ENV GERRIT_WAR ${GERRIT_HOME}/bin/gerrit.war

# Add Gerrit packages to repository
RUN echo "deb mirror://mirrorlist.gerritforge.com/deb gerrit contrib" > /etc/apt/sources.list.d/GerritForge.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 1871F775

# Allow remote connectivity and sudo
RUN apt-get update
RUN apt-key update
RUN apt-get -y install openssh-client sudo

# Install OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN apt-get -y install openjdk-8-jdk
RUN apt-get -y install gerrit=$GERRIT_VERSION-$GERRIT_RELEASE && rm -f ${GERRIT_HOME}/logs/*


# Add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
# RUN useradd -d "${GERRIT_HOME}" -s /sbin/nologin "${GERRIT_USER}"
RUN adduser "${GERRIT_USER}" sudo


# Copy entrypoint scripts to a known location COPY
COPY gerrit-entrypoint.sh /
COPY gerrit-start.sh /
RUN  chmod +x /gerrit*.sh


USER ${GERRIT_USER}

# Create the directory for gerrit beforehand and give the ownership to the new user.
RUN sudo -u  ${GERRIT_USER} mkdir -p $GERRIT_SITE



# Install all gerrit plugins
RUN java -jar ${GERRIT_HOME}/bin/gerrit.war init --batch --install-all-plugins -d ${GERRIT_HOME}


# Allow incoming traffic
EXPOSE 29418 8080
VOLUME ["${GERRIT_HOME}/git", "${GERRIT_HOME}/index", "${GERRIT_HOME}/cache", "${GERRIT_HOME}/db", "${GERRIT_HOME}/etc"]

ENTRYPOINT ["/gerrit-entrypoint.sh"]

# Start Gerrit
CMD ["/gerrit-start.sh"]

