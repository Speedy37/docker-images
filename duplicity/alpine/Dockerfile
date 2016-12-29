FROM alpine:latest
MAINTAINER Vincent Rouille <vincent@speedy37.fr>

RUN apk add --no-cache duplicity lftp librsync  \
 && apk add --no-cache py-boto py-paramiko  py-pip py-cryptography 	ca-certificates \
 && apk add --no-cache py-cffi \
 && apk add --no-cache build-base \
 && pip install --upgrade pip && pip install pyrax && rm -r /root/.cache

VOLUME /root/.cache/duplicity

CMD ["duplicity", "--help"]
