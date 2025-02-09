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
You can use the IDE you want for accessing the container, but the container exposes the code-server IDE on port 8889. For saving configuration and extension you need to declare volumes for the following paths:

- Configuration:    /root/.config/code-server 
- Extensions:       /root/.local/share/code-server

Alternatively, you should change the /root part with the name user (i.e. /your_user) you specified for running the container.

## Projects root
This image comes with a default working directory located at /projects. The idea is to mount the root of all projects from the host into /projects directory or, alternatively, mount each project root into a sub-directory of /projects.

## Python Development
This image is useful to be used with tools and IDEs that allow to manage remote container connections, like VSCode. The best way to proceed is to create a virtual environment into the project directory from the container and install all necessary Python libraries in it. In this way, the installed libraries will persist among container restarts. Note that this image comes without any sort of Python package.

## SSH daemon
This image comes with a preconfigured SSH daemon running as default command for container. The SSH daemon has been used by me many times for setting up development container clusters, for testing distributed environments which require SSH passwordless access to the worker nodes. As it can be seen in the Dockerfile, the SSH daemon has a defaut access password for root, i.e. 'password'. Public key authentication (passwordless) and root login are enabled by default. A default random SSH key is generated at image build time, useful to quickly create a cluster of SSH nodes in your container environment, usable in Docker Swarm, too. Obviously, These settings are not for production purposes. 

NOTE about production purposes: If SSH is needed in production, disable SSH password login and peraphs root login, too, by creating your own user id in the image. Moreover, it is needed to replace default SSH key by mounting your private id_rsa into container path at /root/.ssh/id_rsa, if root login is left enabled, or into /home/your-user/.ssh/id_rsa, if your-user has been created in the Dockerfile or in the running container.

## Docker Hub availability
The latest version of this image, built through GitHub Actions from this repository, is available on the Docker Hub at svgiampa/dev.

## Compose file
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
