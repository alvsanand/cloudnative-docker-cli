# Build arguments
ARG UBUNTU_VERSION=20.04

LABEL org.opencontainers.image.authors="alvsanand@gmail.com"
LABEL org.opencontainers.image.source=https://github.com/alvsanand/cloudnative-docker-cli

FROM ubuntu:$UBUNTU_VERSION

# Install basic components
RUN apt-get update \
 && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    jq \
    python3 python3-pip \
    telnet \
    unzip \
    vim \
    wget \
    zip

# Install Ansible
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common \
 && add-apt-repository --yes --update ppa:ansible/ansible \
 && apt-get remove -y software-properties-common \
 && apt-get autoremove -y \
 && apt update \
 && apt install -y ansible

# Install AWS CLI
RUN pip3 install --no-cache-dir awscli

# Install Azure CLI
RUN pip3 install --no-cache-dir azure-cli

# Install Github CLI
RUN curl -sL https://webinstall.dev/gh | bash \
  && mv $(readlink -f /root/.local/bin/gh) /usr/local/bin/gh \
  && rm -Rf /root/.local \
  && rm -Rf /root/.cache \
  && rm -rf /root/Downloads

# Install Google Cloud SDK
RUN cd /usr/lib && curl -sSL https://sdk.cloud.google.com | bash -s -- --install-dir=/usr/local/lib/ --disable-prompts \
  && rm -rf /usr/local/lib/google-cloud-sdk/.install

# Install Kubectl
RUN curl -o /usr/local/bin/kubectl -sL https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Install Terraform
ARG SINCE_TERRAFORM_VERSION=0.12

RUN git clone https://github.com/kamatama41/tfenv.git /usr/local/lib/tfenv \
 && ln -s /usr/local/lib/tfenv/bin/* /usr/local/bin \
 && tfenv install latest \
 && tfenv use latest

# Install Vault
RUN curl -Ss https://releases.hashicorp.com/vault/ | sed -rn 's|.+vault_([0-9.]+).+|\1|p' | sort --version-sort | uniq | tail -1 | xargs -I {} curl -Ss "https://releases.hashicorp.com/vault/{}/vault_{}_linux_amd64.zip" -o /tmp/vault_linux_amd64.zip \
 && unzip /tmp/vault_linux_amd64.zip -d /tmp \
 && mv /tmp/vault /usr/local/bin \
 && rm /tmp/vault_linux_amd64.zip

# Install other cool commands
RUN curl -sL https://webinstall.dev/k9s | bash \
  && mv $(readlink -f /root/.local/bin/k9s) /usr/local/bin/k9s \
  && rm -Rf /root/.local \
  && rm -Rf /root/.cache \
  && rm -rf /root/Downloads

# Create user
ARG USERNAME=cloudnative-docker-cli
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --create-home  --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && chown -R $USER_UID:$USER_GID /home/$USERNAME \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Final setup
COPY bin/*.sh /usr/local/bin
RUN chmod +x /usr/local/bin/*

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/*

ENV PATH $PATH:/usr/local/lib/google-cloud-sdk/bin

WORKDIR /home/$USERNAME
USER $USERNAME

# Set entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["bash"]