# Use the official HashiCorp Vault image as the base
FROM docker.io/hashicorp/vault:1.17.3

# Switch to root user to install packages
USER root

RUN apk add --no-cache curl jq coreutils

# Optional: Verify installations
 RUN echo "Verifying curl:" && curl --version
 RUN echo "Verifying jq:" && jq --version
 RUN echo "Verifying base64:" && base64 --version
 RUN echo "Verifying vault:" && vault --version

USER vault
