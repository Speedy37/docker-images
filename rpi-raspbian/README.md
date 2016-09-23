rpi-raspbian
===================

[Raspbian](http://www.raspbian.org/) image for docker on raspberry pi.


Generating
----------

This image is built on a raspberry pi running raspbian. 
A chroot is created using debootstrap and compressed so docker can add the root filesystem during the build process. 
The compression requires xz-utils (or something similar) to be installed on the build machine.  

`mkimage-raspbian.sh` is used to build and configure the chroot.
This script **heavily** borrows from docker's [mkimage.sh](https://github.com/docker/docker/blob/master/contrib/mkimage.sh) script.

Building
--------
If you want to build this image yourself, run the following to generate the compressed chroot.

```bash
$ rm *.tar.xz
$ ./mkimage-raspbian.sh wheezy
$ docker build -t rpi-raspbian:wheezy .
```

