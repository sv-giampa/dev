#!/bin/sh

if [ -e /projects/startup.sh ]; then
    /projects/startup.sh &
fi

/usr/sbin/sshd -D

