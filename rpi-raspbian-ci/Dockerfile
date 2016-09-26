FROM speedy37/rpi-raspbian:wheezy
RUN apt-get update \
 && apt-get install -y curl gcc-4.7 g++-4.7 libc-dev libgmp-dev python git make
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-4.7 30 \
 && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-4.7 30 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 20 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.7 20
