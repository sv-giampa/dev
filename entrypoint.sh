#!/bin/sh

if [ -e /projects/autorun.sh ]; then
    /projects/autorun.sh &
fi

python3 -c "import tensorflow as tf; tf.config.list_physical_devices()"

/usr/sbin/sshd -D

