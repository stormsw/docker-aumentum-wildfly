#!/usr/bin/docker
# based on 14.10 Ubuntu
FROM ubuntu:utopic
MAINTAINER Alexander Varchenko <alexander.varchenko@gmail.com>

# install software-properties-common (ubuntu >= 12.10)
# to be able to use add-apt-repository
RUN apt-get update && apt-get install -y software-properties-common
# add repository for web-update
RUN add-apt-repository ppa:webupd8team/java

#Oracle jdk8 (possible to use 6,7,8)

# accept Oracle license
RUN echo /usr/bin/debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN echo /usr/bin/debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections

RUN apt-get update && apt-get install -y \
  oracle-java8-installer \
  xmlstarlet \
  libsaxon-java \
  augeas-tools \
  unzip

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first user on Debian/Ubuntu,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss

#slim down image size
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss

# Specify the user which should be used to execute all commands below
USER jboss
#export Java home
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Wildfly part

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 8.2.0.Final

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME && \
curl http://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz | \
tar zx && \
mv $HOME/wildfly-$WILDFLY_VERSION $HOME/wildfly

# Set the JBOSS_HOME env variable
ENV JBOSS_HOME /opt/jboss/wildfly

# Expose the ports we're interested in
EXPOSE 8080
EXPOSE 9990
# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
