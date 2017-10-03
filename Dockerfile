FROM ubuntu:16.04
LABEL "author"="Hasan Comak"

ENV GERRIT_VERSION "2.13.9"
ENV GERRIT_RELEASE 1

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
RUN apt-get -y install openssh-client sudo curl libcgi-pm-perl


# Add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
RUN useradd -d "${GERRIT_HOME}"  "${GERRIT_USER}" && echo "${GERRIT_USER}:password" | chpasswd && adduser "${GERRIT_USER}" sudo


# Install OpenJDK and Gerrit in two subsequent transactions
# (pre-trans Gerrit script needs to have access to the Java command)
RUN apt-get -y install openjdk-8-jdk
RUN apt-get -y install gerrit=$GERRIT_VERSION-$GERRIT_RELEASE && rm -f ${GERRIT_HOME}/logs/*


# Copy entrypoint scripts to a known location COPY
COPY gerrit-entrypoint.sh /
COPY gerrit-start.sh /
RUN  chmod +x /gerrit*.sh


USER ${GERRIT_USER}

# Create the directory for gerrit beforehand and give the ownership to the new user.
RUN sudo -u  ${GERRIT_USER} mkdir -p $GERRIT_HOME

# Install all gerrit plugins
#RUN sudo -u ${GERRIT_USER} java -jar ${GERRIT_HOME}/bin/gerrit.war init --batch --install-all-plugins -d ${GERRIT_HOME}
# Remove all repos for later db selection
# RUN rm -rf $GERRIT_HOME/git/*

# Download mysql driver
RUN curl -fSsL http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.6/mysql-connector-java-5.1.6.jar -o ${GERRIT_HOME}/lib/mysql-connector-java.jar

# Allow incoming traffic
EXPOSE 29418 8080
VOLUME ["${GERRIT_HOME}/git", "${GERRIT_HOME}/index", "${GERRIT_HOME}/cache", "${GERRIT_HOME}/db", "${GERRIT_HOME}/etc"]

ENTRYPOINT ["/gerrit-entrypoint.sh"]

# Start Gerrit
CMD ["/gerrit-start.sh"]

