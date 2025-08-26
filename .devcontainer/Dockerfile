FROM mcr.microsoft.com/devcontainers/python:1-3.12-bullseye

LABEL org.opencontainers.image.source="https://github.com/jhoareaumarion/devcontainers"
LABEL org.opencontainers.image.description="Ansible + Kubernetes + OpenTofu for VS Code"
LABEL org.opencontainers.image.licenses="MPL 2.0"

# Copy the installation script
COPY tofu/install_tofu.sh /tmp/install_tofu.sh

# Run the script
RUN /tmp/install_tofu.sh && \
    rm /tmp/install_tofu.sh

# Copy the installation script
COPY kubectl/install_kubectl.sh /tmp/install_kubectl.sh

# Run the script
RUN /tmp/install_kubectl.sh && \
    rm /tmp/install_kubectl.sh

# Copy the installation script
COPY ansible/install_ansible.sh /tmp/install_ansible.sh

# Run the script
RUN /tmp/install_ansible.sh && \
    rm /tmp/install_ansible.sh

COPY ansible/post_create.sh /usr/local/bin/post_create.sh
RUN chmod +x /usr/local/bin/post_create.sh
WORKDIR /workspace

CMD ["/bin/bash"]