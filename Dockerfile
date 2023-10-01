FROM alpine:latest

USER root
WORKDIR /root

# utilities
RUN apk add htop
RUN apk add screen
RUN apk add zip
RUN apk add nano

# network utils
RUN apk add wget

# python
RUN apk add python3
RUN apk add py3-pip
RUN python3 -m pip install --upgrade pip setuptools

# java
RUN apk add gradle
RUN apk add openjdk8
RUN apk add openjdk17
RUN apk add maven

# install and configure git
RUN apk add git
RUN git config --global commit.gpgsign false

# configure ssh daemon
RUN apk add openssh
RUN if ! [ -d /var/run/sshd ]; then mkdir /var/run/sshd; fi
RUN echo 'root:password' | chpasswd
RUN sed -i 's/^[# ]*PermitRootLogin .*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -i 's/^[# ]*PubkeyAuthentication .*$/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
RUN ssh-keygen -A
EXPOSE 22

# create workspace directory, set it as working dir for shells and expose it as a volume
RUN mkdir /workspace
WORKDIR /workspace
RUN echo "cd /workspace" >> /root/.bashrc
RUN echo "cd /workspace" >> /root/.profile
VOLUME ["/workspace"]

# executes the optional install script
COPY ./install.sh /install.sh
RUN chmod 777 /install.sh
RUN /install.sh

# setup entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
CMD ["/entrypoint.sh"]
