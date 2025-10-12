FROM alpine:3.22

# Install essential packages
RUN apk add --no-cache \
    openssh \
    sudo \
    curl \
    git \
    build-base \
    neovim \
    tmux \
    zsh \
    bash \
    shadow \
    ca-certificates

# Setup SSH
RUN ssh-keygen -A && \
    mkdir -p /var/run/sshd

# Create a user for development (with zsh as default shell)
RUN adduser -D -s /bin/zsh dev && \
    echo "dev:dev" | chpasswd && \
    echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install mise for the dev user
USER dev
WORKDIR /home/dev
RUN curl https://mise.run | sh && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc

USER root

# Configure SSH
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Create .ssh directory for the dev user
RUN mkdir -p /home/dev/.ssh && \
    chmod 700 /home/dev/.ssh && \
    chown dev:dev /home/dev/.ssh

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
