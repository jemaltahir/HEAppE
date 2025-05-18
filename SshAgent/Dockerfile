FROM alpine AS base
WORKDIR /app

RUN mkdir shared
RUN mkdir scripts;

COPY ["SshAgent/scripts/init.sh", "./scripts/"]
COPY ["SshAgent/scripts/adding_keys.sh", "./scripts/"]

RUN chmod 755 ./scripts/init.sh ./scripts/adding_keys.sh && ls -l ./scripts/
RUN apk update 
RUN apk add --no-cache openssh-client 
RUN apk add --no-cache bash

ENTRYPOINT ["bash", "./scripts/init.sh"]