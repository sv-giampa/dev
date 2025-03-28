#!/bin/sh
nvidia-smi

# create workspace if it does not exist
if [ ! -d $WORKSPACE ]; then
    mkdir $WORKSPACE
fi

# change current directory to workspace
cd $WORKSPACE

# setup workspace as starting workdir for shell
echo "cd $WORKSPACE" >> ~/.bashrc
echo "cd $WORKSPACE" >> ~/.profile

if [ $(id -u) -eq 0 ]; then
    mkdir -p $WORKSPACE/.ssh;
    # persist container SSH fingerprints on workspace
    if [ ! -d $WORKSPACE/.ssh/etc_ssh ]; then
        cp -r /etc/ssh $WORKSPACE/.ssh/etc_ssh;
    fi
    if [ -d /etc/ssh ]; then
        rm -rf /etc/ssh; 
    fi
    ln -s $WORKSPACE/.ssh/etc_ssh /etc/ssh;
else
    echo """
        [WARNING]   Cannot persist container fingerprints in /etc/ssh, as root user is needed. 
                    Mount an external volume in /etc/ssh for persisting fingerprints, if you need to.
    """
fi

# generate SSH key if not present
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -b 4096 -f ~/.ssh/id_rsa -N '' < y
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

# link SSH public key and authorized-keys to the workspace
mkdir -p $WORKSPACE/.ssh;
if [ -f $WORKSPACE/.ssh/id_rsa.pub ]; then rm -f $WORKSPACE/.ssh/id_rsa.pub; fi
ln -s ~/.ssh/id_rsa.pub $WORKSPACE/.ssh/id_rsa.pub
if [ ! -f ~/.ssh/authorized_keys ]; then touch ~/.ssh/authorized_keys; fi
if [ -f $WORKSPACE/.ssh/authorized_keys ]; then rm -f $WORKSPACE/.ssh/authorized_keys; fi
ln -s ~/.ssh/authorized_keys $WORKSPACE/.ssh/authorized_keys

# set correct permissions on .ssh folder
chmod -R 700 ~/.ssh

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
else
    # if autorun.sh does not exist, create it
    touch $WORKSPACE/autorun.sh
    chmod 777 $WORKSPACE/autorun.sh
    chmod 777 $WORKSPACE
fi

# run ssh daemon for building ssh clusters
/usr/sbin/sshd -D &

# upgrade and run code-server
/run_code_server.sh ${@} &

# keep entrypoint script running
while true; do sleep 100s; done