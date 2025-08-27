FROM mcr.microsoft.com/devcontainers/python:1-3.12-bookworm

LABEL org.opencontainers.image.source="https://github.com/jhoareaumarion/devcontainers"
LABEL org.opencontainers.image.description="Ansible + Kubernetes + OpenTofu for VS Code"
LABEL org.opencontainers.image.licenses="MPL 2.0"

# Copy the installation scripts
COPY tofu/install_tofu.sh /tmp/install_tofu.sh
COPY kubectl/install_kubectl.sh /tmp/install_kubectl.sh
COPY ansible/install_ansible.sh /tmp/install_ansible.sh
COPY bitwarden/install_bw.sh /tmp/install_bw.sh
COPY post_create.sh /usr/local/bin/post_create.sh

# Making post_create runnable
RUN chmod +x /usr/local/bin/post_create.sh

# Run the scripts
RUN /tmp/install_tofu.sh && \
    rm /tmp/install_tofu.sh
RUN /tmp/install_kubectl.sh && \
    rm /tmp/install_kubectl.sh
RUN /tmp/install_ansible.sh && \
    rm /tmp/install_ansible.sh
RUN /tmp/install_bw.sh && \
    rm /tmp/install_bw.sh

WORKDIR /workspace

CMD ["/bin/bash"]