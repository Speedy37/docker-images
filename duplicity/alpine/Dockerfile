FROM alpine:edge
MAINTAINER Vincent Rouille <vincent@speedy37.fr>

RUN apk add --no-cache duplicity lftp librsync \
 && apk add --no-cache py-boto py-paramiko py2-pip py-cryptography ca-certificates \
 && apk add --no-cache py-cffi \
 && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing py-netifaces  \
 && pip install pyrax && rm -r /root/.cache

VOLUME /root/.cache/duplicity

CMD ["duplicity", "--help"]
