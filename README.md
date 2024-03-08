# JPbase
Base image for Java and Python software development. This image is based on Ubuntu Docker image.

# Delivered software
This image delivers some software useful for development of Java and Python projects.

Generic tools:
- htop
- nano
- screen
- zip

Java tools and libraries:
- OpenJDK 1.8
- OpenJDK 17
- Gradle
- Maven

Python tools and libraries
-   Python 3.10
-   Python PIP

## Python Development
This image is useful to be used with tools and IDEs that allow to manage remote container connections, like VSCode. The best way to proceed is to create a virtual environment into the project directory from the container and install all necessary Python libraries in it. In this way, the installed libraries will persist among container restarts. Note that this image comes with just Python, PIP and Venv, nor any sort of library.

# Compose file
The following compose file declare a single service

    version: '3'
    services:
        jp_dev:
            build: .
            networks:
                - dev
            volumes:
                - project:/project
                - root:/root
            restart: unless-stopped
    networks:
        dev:
            attachable: true
    volumes:
        project:
        root:       
