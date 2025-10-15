FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    git \
    xz-utils \
    ca-certificates \
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

# Install Nix package manager (multi-user mode)
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Configure Nix for the dev user
RUN mkdir -p /home/dev/.config/nix && \
    echo "experimental-features = nix-command flakes" > /home/dev/.config/nix/nix.conf && \
    chown -R dev:dev /home/dev/.config

# Add Nix to the dev user's profile
RUN echo 'if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then' >> /home/dev/.bashrc && \
    echo '  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' >> /home/dev/.bashrc && \
    echo 'fi' >> /home/dev/.bashrc

# Ensure nix-daemon starts
RUN mkdir -p /etc/systemd/system-generators

EXPOSE 22

CMD /nix/var/nix/profiles/default/bin/nix-daemon & /usr/sbin/sshd -D -e
