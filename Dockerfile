FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup SSH
RUN mkdir -p /var/run/sshd

# Create a user for development
RUN useradd -m -s /bin/bash dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
