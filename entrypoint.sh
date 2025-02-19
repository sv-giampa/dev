#!/bin/sh
nvidia-smi

WORKSPACE=$1

echo "cd $WORKSPACE" >> ~/.bashrc
echo "cd $WORKSPACE" >> ~/.profile

# persist container SSH fingerprint on workspace
if [ ! -f $WORKSPACE/.ssh/ssh_host_rsa_key.pub ]; then
    cp /etc/ssh/ssh_host_rsa_key.pub $WORKSPACE/.ssh/ssh_host_rsa_key.pub;
fi
if [ -f /etc/ssh/ssh_host_rsa_key.pub]; then 
    rm -f /etc/ssh/ssh_host_rsa_key.pub; 
fi
ln -s $WORKSPACE/.ssh/ssh_host_rsa_key.pub /etc/ssh/ssh_host_rsa_key.pub;

# generate SSH key if not present
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -b 4096 -f ~/.ssh/id_rsa -N '' < y
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

# link SSH public key and authorized-keys to the workspace
if [ -f $WORKSPACE/id_rsa.pub ]; then rm -f $WORKSPACE/id_rsa.pub; fi
ln -s ~/.ssh/id_rsa.pub $WORKSPACE/.ssh/id_rsa.pub
if [ -f $WORKSPACE/authorized_keys ]; then rm -f $WORKSPACE/authorized_keys; fi
ln -s ~/.ssh/authorized_keys $WORKSPACE/.ssh/authorized_keys

# set correct permissions on .ssh folder
chmod 700 ~/.ssh

# persist vscode server config directory into workspace volume
if [ ! -d $WORKSPACE/.vscode-server ]; then 
    if [ -d ~/.vscode-server ]; then 
        mv ~/.vscode-server $WORKSPACE/.vscode-server
    else
        mkdir -p $WORKSPACE/.vscode-server;
    fi
elif [ -d ~/.vscode-server ]; then 
    rm -rf ~/.vscode-server
fi
ln -s $WORKSPACE/.vscode-server ~/.vscode-server

# run autorun script on container startup
if [ -f $WORKSPACE/autorun.sh ]; then
    $WORKSPACE/autorun.sh &
fi

# run ssh daemon for building ssh clusters
/usr/sbin/sshd -D &

# upgrade and run code-server
/run_code_server.sh ${@:2} &

# keep entrypoint script running
while true; do sleep 100s; done