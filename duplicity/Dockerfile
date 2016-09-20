FROM ubuntu:latest
MAINTAINER Vincent Rouille <vincent@speedy37.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get -y install duplicity \
  lftp rsync \
  python-boto python-paramiko python-kerberos python-tk
RUN apt-get -y install rsync python-pip python-cryptography
RUN pip install pyrax && rm -r /root/.cache

VOLUME /root/.cache/duplicity

CMD ["duplicity", "--help"]
