FROM speedy37\duplicity:latest

RUN apt-get update -y \
 && apt-get -y install duply

VOLUME /root/.duply

CMD ["duply", "--help"]