# syntax=docker/dockerfile:1
FROM ubuntu:latest

ENV PACKER_BIN_DIR /usr/local/packer/bin
RUN mkdir --parents $PACKER_BIN_DIR 


# Install.
RUN \
    sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential && \
    apt-get install -y software-properties-common && \
    apt-get install -y byobu curl git htop man unzip vim wget && \
    rm -rf /var/lib/apt/lists/* 


RUN curl https://omnitruck.chef.io/install.sh | bash -s -- -P inspec
RUN type inspec


ENV PACKER_ZIP=https://releases.hashicorp.com/packer/1.8.5/packer_1.8.5_linux_amd64.zip
RUN curl -sSLo /tmp/packer.zip $PACKER_ZIP && \
    unzip /tmp/packer.zip -d $PACKER_BIN_DIR && \
    rm /tmp/packer.zip

ENV PATH $PATH:$PACKER_BIN_DIR

# check that packer is correctly installed
RUN type packer

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]