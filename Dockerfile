#    Copyright 2024 Salvatore Giampà
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

FROM ubuntu:22.04

USER root
WORKDIR /root

COPY --chmod=777 apt_install /apt_install

# install utility software packages
RUN /apt_install software-properties-common
RUN /apt_install inetutils-ping net-tools wget
RUN /apt_install htop screen zip nano
	
# install and configure git
RUN /apt_install git
RUN DEBIAN_FRONTEND=noninteractive git config --global commit.gpgsign false

# intall Python
RUN /apt_install python3 python3-pip python3-venv
RUN python3 -m pip install --upgrade pip setuptools

# install Open JDK 8
RUN /apt_install openjdk-8-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/' >> ~/.bashrc
RUN /apt_install gradle maven

# Configure SSH daemon
RUN /apt_install openssh-server
RUN if ! [ -d /var/run/sshd ]; then mkdir /var/run/sshd; fi
RUN echo 'root:password!!' | chpasswd
RUN sed -i 's/^[# ]*PermitRootLogin .*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -i 's/^[# ]*PubkeyAuthentication .*$/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
RUN service ssh start

# generate ssh keys for all instances of this image (useful for building SSH clusters on docker compose)
RUN ssh-keygen -b 4096 -f /root/.ssh/id_rsa -N '' << y
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# create projects directory, set it as working dir for shells
RUN mkdir /projects
WORKDIR /projects
RUN echo "cd /projects" >> /root/.bashrc
RUN echo "cd /projects" >> /root/.profile

# executes the optional install script
COPY ./install.sh /install.sh
RUN chmod 777 /install.sh
RUN /install.sh

# install Keras-GPU, pandas and numpy
RUN pip install tensorflow[and-cuda] pandas numpy

# create autorun script
RUN touch /projects/autorun.sh
RUN chmod 777 /projects/autorun.sh

# setup entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
CMD ["/entrypoint.sh"]