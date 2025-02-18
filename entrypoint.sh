#!/bin/sh
nvidia-smi

echo "cd /projects" >> ~/.bashrc
echo "cd /projects" >> ~/.profile

if [ ! -f /home/user/.ssh/id_rsa ]; then
    ssh-keygen -b 4096 -f /home/user/.ssh/id_rsa -N '' < y
    cat /home/user/.ssh/id_rsa.pub >> /home/user/.ssh/authorized_keys
fi

if [ -f /projects/id_rsa.pub ]; then rm -f /projects/id_rsa.pub; fi
ln -s ~/.ssh/id_rsa.pub /projects/.ssh/id_rsa.pub

if [ -f /projects/authorized_keys ]; then rm -f /projects/authorized_keys; fi
ln -s ~/.ssh/authorized_keys /projects/.ssh/authorized_keys

chmod 700 ~/.ssh

if [ ! -d /projects/.vscode-server ]; then 
    if [ -d ~/.vscode-server ]; then 
        mv ~/.vscode-server /projects/.vscode-server
    else
        mkdir -p /projects/.vscode-server;
    fi
elif [ -d ~/.vscode-server ]; then 
    rm -rf ~/.vscode-server
fi
ln -s /projects/.vscode-server ~/.vscode-server

if [ -e /projects/autorun.sh ]; then
    /projects/autorun.sh &
fi

# run ssh daemon for building ssh clusters
/usr/sbin/sshd -D &

# install and run code-server
/run_code_server.sh $@ &

# keep entrypoint script running
while true; do sleep 100s; done