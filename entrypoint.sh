#!/bin/sh

nvidia-smi

if [ -e /projects/autorun.sh ]; then
    /projects/autorun.sh &
fi

# run ssh daemon for building ssh clusters
/usr/sbin/sshd -D &

# install and run code-server
/run_code_server.sh $@ &

# keep entrypoint script running
while true; do sleep 100s; done