FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    git \
    build-essential \
    tmux \
    zsh \
    bash \
    ca-certificates \
    ripgrep \
    unzip \
    wget \
    fontconfig \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Nerd Font (FiraCode)
RUN mkdir -p /usr/share/fonts/nerd-fonts && \
    cd /tmp && \
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip && \
    unzip FiraCode.zip -d FiraCode && \
    cp FiraCode/*.ttf /usr/share/fonts/nerd-fonts/ && \
    fc-cache -fv && \
    rm -rf FiraCode FiraCode.zip

# Setup SSH
RUN mkdir -p /var/run/sshd

# Create a user for development (with zsh as default shell)
RUN useradd -m -s /bin/zsh dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install mise for the dev user
USER dev
WORKDIR /home/dev

RUN curl https://mise.run | sh && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

# Install Neovim via mise
RUN /home/dev/.local/bin/mise use -g neovim@latest

USER root

# Configure SSH
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]