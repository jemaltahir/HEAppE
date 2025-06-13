FROM image-registry.apps.2.rahti.csc.fi/test-heappe-app/vault-base:1.17.3

# Switch to root to install packages
USER root

# Install bash (for your scripts), curl, jq, and netcat (for readiness checks)
RUN apk update \
 && apk add --no-cache \
      bash \
      curl \
      jq \
      netcat-openbsd \
 && rm -rf /var/cache/apk/*


RUN mkdir -p /opt && chown vault:vault /opt

USER vault

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["server", "-config=/vault/config/vault.hcl"]
