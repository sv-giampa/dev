#!/bin/sh

nvidia-smi

if [ -e /home/workspace/autorun.sh ]; then
    /home/workspace/autorun.sh &
fi

# run ssh daemon for building ssh clusters
/usr/sbin/sshd -D &

# start OpenVSCode Server
#${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server --help
${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server --without-connection-token --server-base-path $BASE_URL --host 0.0.0.0 --port 8889 --server-data-dir /config/openvscode/server --user-data-dir /config/openvscode/user --extensions-dir /config/openvscode/extensions /projects &

# keep entrypoint script running
while true; do sleep 100s; done

