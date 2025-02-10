#!/bin/sh

nvidia-smi

if [ -e /projects/autorun.sh ]; then
    /projects/autorun.sh &
fi

# run ssh daemon for building ssh clusters
/usr/sbin/sshd -D &

# start code-server
mkdir /cert
openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /cert/code_server.crt -keyout /cert/code_server.key -subj "/C=/ST=/L=/O=/CN="
code-server  /projects --bind-addr 0.0.0.0 --port 8889 --cert "/cert/code_server.crt" --cert-key "/cert/code_server.key" &

# keep entrypoint script running
while true; do sleep 100s; done

