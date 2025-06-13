# vault-helper.Dockerfile
FROM alpine:3.20

# Install needed tools
RUN apk add --no-cache bash curl jq

# Install Vault CLI
RUN wget -q https://releases.hashicorp.com/vault/1.17.3/vault_1.17.3_linux_amd64.zip \
    && unzip vault_1.17.3_linux_amd64.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/vault \
    && rm vault_1.17.3_linux_amd64.zip

WORKDIR /opt

ENTRYPOINT ["/bin/bash"]
