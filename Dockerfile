#
# USAGE: docker build . -t sample-java ; docker run -it -p 8080:8080 sample-java
#
FROM tomcat:9.0.26-jdk13-openjdk-oracle
#
# adding maven in order to build the app
#
ARG MAVEN_VERSION=3.6.2
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
#
# building the app
#
ARG APP_NAME=webjavadocker
ARG APP_VERSION=1.0-SNAPSHOT

RUN mkdir -p /app
ADD src /app/src
ADD pom.xml /app/pom.xml
WORKDIR /app
RUN mvn package
WORKDIR /usr/local/tomcat

#
# clean and deploy
#
RUN rm -rf /usr/local/tomcat/webapps/*
RUN cp /app/target/${APP_NAME}-${APP_VERSION}.war /usr/local/tomcat/webapps/ROOT.war
