# syntax=docker/dockerfile:1
FROM ubuntu:latest

# Install.
RUN \
    sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential && \
    apt-get install -y software-properties-common && \
    apt-get install -y byobu curl git htop man unzip vim wget && \
    apt install --reinstall coreutils \
    rm -rf /var/lib/apt/lists/* \
    curl https://omnitruck.chef.io/install.sh | bash -s -- -P inspec \
    --mount=type=secret,id=github_token \
    cat /run/secrets/github_token 

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Define default command.
CMD ["bash"]