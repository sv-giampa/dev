# Python and Java development image
Base image for Python and Java software development.

Based on Ubuntu base Docker image, I built this image for using in my development projects.

This README collects some general notes to deal with some needs that I encountered in my projects.

# Delivered software
This image delivers some software useful for development of Java and Python projects.

Generic tools:
- htop
- nano
- screen
- zip
- git

Java tools and libraries:
- OpenJDK 1.8
- Gradle
- Maven

Python tools and libraries
- Python 3
- Python PIP
- Python Venv

# IDE
You can use an SSH IDE you want for accessing the container (eg., VSCode desktop client), but the container exposes the code-server IDE on port 8889.

## Projects root
This image comes with a default working directory located at /projects. The idea is to mount the root of all projects from the host into /projects directory or, alternatively, mount each project root into a sub-directory of /projects.

## Python development
This image is useful to be used with tools and IDEs that allow to manage remote container connections, like VSCode. The best way to proceed is to create a virtual environment into the project directory from the container and install all necessary Python libraries in it. In this way, the installed libraries will persist among container restarts. Note that this image comes without any sort of Python package.

## Scala/Spark/Delta Lake development
This image comes with latest compatible versions of Scala, Spark and Delta Lake.

## SSH daemon
This image comes with a preconfigured SSH daemon running as default command for container. The SSH daemon has been used by me many times for setting up development container clusters, for testing distributed environments which require SSH passwordless access to the worker nodes. As it can be seen in the Dockerfile, the SSH daemon has a defaut access password for root, i.e. 'password'. Public key authentication (passwordless) and root login are enabled by default. A default random SSH key is generated at image build time, useful to quickly create a cluster of SSH nodes in your container environment, usable in Docker Swarm, too. 

## Docker Hub availability
The latest version of this image, built through GitHub Actions from this repository, is available on the Docker Hub at svgiampa/dev.

# Recommended volumes
For persisting data and configuration you should mount the following paths:

- **/projects**: the root of your workspace
- **/etc/ssh**: persists container's host fingerprints and ssh daemon configuration
- **/root**: persists the configuration of installed software, such as vscode-server, code-server, docker login, git configuration, metals, and so on;
- **/var/run/docker.sock**: if you want use docker in your containerized environment.

Note: mount **/home/\<user\>** instead of **/root** if you run the container in rootless mode with the specified **\<user\>**.

# Environment variables
Some environment variables can be specified. The following are the variable with their default values:

- **NVIDIA_VISIBLE_DEVICES**=all: select NVIDIA devices visible to the container;
- **NVIDIA_DRIVER_CAPABILITIES**=compute,utility: select NVIDIA capabilities available to the container;
- **DISABLE_CODESERVER**=0: disable code-server if set to 1;
- **DISABLE_SSH**=0: disable SSH daemon if set to 1.

# Docker Compose
The following Docker-Compose structures allow to create a dev container with availability of nVidia GPUs (for using frameworks like TensorFlow and Keras).

The next Docker-Compose structure is useful to generate a dev container from the root of this repository:

    version: '3'
    services:
        python-dev:
            build: .
            environment:
            - NVIDIA_VISIBLE_DEVICES=all
            networks:
                - dev
            volumes:
                - <your projects root>:/projects
            restart: unless-stopped
    networks:
        dev:
            attachable: true
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]

The following Docker-Compose allows to create the same container from the released Docker-Hub image. Obviously, if you do not trust, you can build your own image and replace the image name with your:

    version: '3'
    services:
        python-dev:
            image: svgiampa/dev:latest
            environment:
            - NVIDIA_VISIBLE_DEVICES=all
            networks:
                - dev
            volumes:
                - <your projects root>:/projects
            restart: unless-stopped
    networks:
        dev:
            attachable: true
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
