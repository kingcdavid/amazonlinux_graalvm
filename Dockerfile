FROM amd64/amazonlinux:latest
RUN echo "These are the proxy settings"
RUN export HTTP_PROXY=""
RUN export HTTPS_PROXY=""
RUN echo ${HTTPS_PROXY}
RUN curl http://amazonlinux.default.amazonaws.com/2/core/latest/x86_64/mirror.list
#GraalVM Installation
RUN yum install -y gcc gcc-c++ libc6-dev zlib1g-dev zlib zlib-devel curl bash

ENV GRAAL_VERSION 21.1.0
ENV GRAAL_FILENAME graalvm-ce-java11-linux-amd64-${GRAAL_VERSION}.tar.gz

RUN curl -4 -L https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAAL_VERSION}/${GRAAL_FILENAME} -o /tmp/${GRAAL_FILENAME}

RUN tar -zxvf /tmp/${GRAAL_FILENAME} -C /tmp
RUN mv /tmp/graalvm-ce-java11-${GRAAL_VERSION} /usr/lib/graalvm
RUN rm -rf /tmp/*

ENV PATH /usr/lib/graalvm/bin:${PATH}
ENV JAVA_HOME /usr/lib/graalvm/

RUN gu install native-image

#Maven installation
RUN yum install -y wget
RUN wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
RUN sed -i s/\$releasever/7/g /etc/yum.repos.d/epel-apache-maven.repo
RUN yum install -y apache-maven
RUN echo ${HTTP_PROXY}
RUN echo ${HTTPS_PROXY}

#Native Compilation
WORKDIR /my-app/
RUN mvn clean package -Pnative
RUN chmod 755 target/function.zip
