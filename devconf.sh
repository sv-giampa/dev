#!/bin/bash

# setup .devconf directory
export DEVCONF=$WORKSPACE/.devconf
mkdir -p $DEVCONF

function link_to_devconf {
    # usage: link_to_devconf <f or d> <src> <dest relative to .devconf>
    local TYPE=$1
    local SRC=$2
    local DST=$DEVCONF/$3
    mkdir -p $(dirname "$DST")
    if [ "$TYPE" = "d" ]; then
        if [ ! -d $DST ]; then  
            rm -rf $DST
            if [ -d $SRC ]; then 
                mv $SRC $DST
            else
                mkdir -p $DST;
            fi
        fi
    else 
        if [ ! -f $DST ]; then 
            rm -rf $DST
            if [ -f $SRC ]; then 
                mv $SRC $DST
            else
                touch $DST;
            fi
        fi
    fi
    if [ -e $SRC ]; then 
        rm -rf $SRC
    fi
    ln -s $DST $SRC
}

link_to_devconf f ~/.ssh/known_hosts ssh/keys/known_hosts
link_to_devconf f ~/.ssh/authorized_keys ssh/keys/authorized_keys
link_to_devconf f ~/.ssh/id_rsa ssh/keys/id_rsa
link_to_devconf f ~/.ssh/id_rsa.pub ssh/keys/id_rsa.pub
chmod -R 700 $DEVCONF/ssh

link_to_devconf d ~/.docker docker
link_to_devconf f ~/.gitconfig gitconfig
link_to_devconf d ~/.vscode-server vscode/vscode-server
link_to_devconf d ~/.code-server vscode/code-server
link_to_devconf d /etc/ssh ssh_daemon

# create autorun script on container startup
if [ ! -f $DEVCONF/autorun.sh ]; then
    touch $DEVCONF/autorun.sh
    chmod 777 $DEVCONF/autorun.sh
    chmod 777 $DEVCONF
fi

echo $DEVCONF