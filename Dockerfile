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

COPY apt_install /apt_install
RUN chmod 777 /apt_install

# install utility software packages
RUN /apt_install software-properties-common
RUN /apt_install inetutils-ping net-tools wget curl
RUN /apt_install htop screen zip nano

# install docker client; it needs volume mount for the host /var/run/docker.dock, only if docker is needed
RUN /apt_install docker.io
	
# install and configure git
RUN /apt_install git
RUN DEBIAN_FRONTEND=noninteractive git config --global commit.gpgsign false

# install Open JDK 8
RUN /apt_install openjdk-8-jdk-headless
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/' >> ~/.bashrc
RUN /apt_install gradle maven

# install Python
RUN /apt_install python3 python3-pip python3-venv
RUN pip install --upgrade pip setuptools

RUN add-apt-repository ppa:deadsnakes/ppa
RUN /apt_install python3.11 python3.11-distutils
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# basic data science and engineering utilities
RUN /apt_install graphviz
RUN pip install pandas numpy matplotlib seaborn scikit-learn scipy ipykernel ipython

ENV SCALA_VERSION=2.12.15
ENV SPARK_VERSION=3.2.1
ENV DELTA_VERSION=1.2.1

# install Scala
RUN wget https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz && \
    tar -xzf scala-${SCALA_VERSION}.tgz -C /usr/local && \
    rm scala-${SCALA_VERSION}.tgz && \
    ln -s /usr/local/scala-${SCALA_VERSION}/bin/scala /usr/local/bin/scala && \
    ln -s /usr/local/scala-${SCALA_VERSION}/bin/scalac /usr/local/bin/scalac

# install Spark
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz -C /usr/local && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    ln -s /usr/local/spark-${SPARK_VERSION}-bin-hadoop3.2 /usr/local/spark

# install Delta Lake
RUN wget https://repo1.maven.org/maven2/io/delta/delta-core_2.12/${DELTA_VERSION}/delta-core_2.12-${DELTA_VERSION}.jar -P /usr/local/spark/jars/

# Imposta le variabili d'ambiente di Spark
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$SPARK_HOME/bin:$PATH:$JAVA_HOME/bin

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
COPY ./run_code_server.sh /run_code_server.sh
RUN chmod 777 /run_code_server.sh

# Configure SSH daemon
RUN /apt_install openssh-server
RUN if [ ! -d /var/run/sshd ]; then mkdir /var/run/sshd; fi
#RUN echo 'root:password!!' | chpasswd
RUN sed -i 's/^[# ]*PermitRootLogin .*$/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
RUN sed -i 's/^[# ]*PubkeyAuthentication .*$/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
RUN mkdir -p ~/.ssh
RUN service ssh start

# executes the optional install script
COPY ./install.sh /install.sh
RUN chmod 777 /install.sh
RUN /install.sh

# create projects directory, set it as working dir for shells
ENV WORKSPACE="/projects"

# add devconf.sh
COPY devconf.sh /devconf.sh
RUN chmod 777 /devconf.sh

# setup entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh
CMD ["/entrypoint.sh"]

# setup ennvironment
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# volumes
VOLUME [ "${WORKSPACE}" ]