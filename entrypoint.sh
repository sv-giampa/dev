#!/bin/sh

nvidia-smi

if [ -e /projects/autorun.sh ]; then
    /projects/autorun.sh &
fi

/usr/sbin/sshd -D

