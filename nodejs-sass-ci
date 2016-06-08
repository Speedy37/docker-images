FROM node:6.2
MAINTAINER Vincent Rouillé <v-rouille@logitud.fr>
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      gem \
      git
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && gem install sass
