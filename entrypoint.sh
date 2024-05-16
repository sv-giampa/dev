#!/bin/sh

if [ -e /projects/startup.sh ]; then
    /projects/startup.sh &
fi

python3 -c "import tensorflow as tf; tf.config.list_physical_devices()"

/usr/sbin/sshd -D

