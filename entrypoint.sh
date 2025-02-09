#!/bin/sh

nvidia-smi

if [ -e /projects/autorun.sh ]; then
    /projects/autorun.sh &
fi

# run ssh daemon for building ssh clusters
/usr/sbin/sshd -D &

# start code-server
code-server --port 8889 --bind-addr 0.0.0.0 /projects &

# keep entrypoint script running
while true; do sleep 100s; done

