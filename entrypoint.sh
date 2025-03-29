#!/bin/bash
nvidia-smi

# create workspace if it does not exist
if [ ! -d $WORKSPACE ]; then
    mkdir $WORKSPACE
fi

# setup devconf directory
echo "Setting up .devconf directory"
export DEVCONF=$(/devconf.sh | tail -1)

# change current directory to workspace
cd $WORKSPACE

# setup workspace as starting workdir for shell
echo "cd $WORKSPACE" >> ~/.bashrc
echo "cd $WORKSPACE" >> ~/.profile

# set correct permissions on .ssh folder
echo "Setting correct permissions on ~/.ssh folder"
chmod -R 700 ~/.ssh

# generate SSH key if not present
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Creating id_rsa private key for SSH connection"
    ssh-keygen -b 4096 -f ~/.ssh/id_rsa -N '' < y
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

# run ssh daemon for building ssh clusters
echo "Starting SSH daemon"
/usr/sbin/sshd -D &

# upgrade and run code-server
echo "Starting code-server"
/run_code_server.sh ${@} &

# run autorun script
echo "Starting $DEVCONF/autorun.sh"
$DEVCONF/autorun.sh &

# keep entrypoint script running
while true; do sleep 100s; done