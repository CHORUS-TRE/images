# README: Building an application Docker Image for the Chorus-TRE Platform

This guide provides a step-by-step process for building a Docker image to run your application on the Chorus-TRE platform. It includes selecting a base image, configuring SSH for accessing private repositories, adding core scripts, and setting up your application.

**1. Choose the Base Distribution**

Start by selecting the base image for your Docker container. For this guide, we’re using Ubuntu 24.04. You can choose a different base image if required by your application.
```dockerfile
# syntax=docker/dockerfile:1
FROM ubuntu:24.04
SHELL ["/bin/bash", "-xe", "-o", "pipefail", "-c"]
```

**2. Configure SSH for Private Repositories**

If your application requires files from a private repository, you’ll need to set up SSH. This setup is temporary and will be removed once CHORUS-TRE repos are switched to public

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends openssh-client
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
```

At the same time you need to add the flag ```--ssh default``` to the ```docker-buildx``` command in the build.sh of your app

**3. Add the core scripts from the CHORUS-TRE repo : we only want the core folder to limit the size of the image.**

**chorus-utils.sh** : the main script that will install all necessary dependencies.\
**-a [app_name1,app_name2]** : allows for installation of additional apps to your image that are provided and tested by the chorus team.

```dockerfile
# ADD 'git@github.com:MY-ORG/my-repo.git#branch:folder' destination_folder
ADD 'git@github.com:CHORUS-TRE/images.git#feat/core-scripts:core' /tmp/core_scripts
RUN cd /tmp/core_scripts/utilities && \
    ./chorus-utils.sh -a terminal && \
    cd .. && mv entrypoint/docker-entrypoint.sh / && \
    mv entrypoint/1-create-user.sh /docker-entrypoint.d && \
    mv entrypoint/2-run-app.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]
```

**4. Add all necessary files and packages usefull to make your application work.**

```dockerfile
ARG APP_NAME
ARG APP_VERSION

WORKDIR /apps/<your_app_name>

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qy && \
    apt-get install --no-install-recommends -qy \
    # Add any additional dependencies here \
    curl unzip package1 package2 && \
    # Get your software from github or wherever it is
    https://github.com/MY-ORG/MY-APP/releases/download/V${APP_VERSION}/MY-APP.${APP_VERSION}.zip && \
    mkdir ./install && \
    unzip -q -d ./install <your-app-name>-${APP_VERSION}.linux64.zip && \
    # Remove all unnecessary files and packages
    rm MY-APP.${APP_VERSION}.linux64.zip && \
    apt-get remove -y --purge curl unzip && \
    apt-get autoremove -y --purge
```

**5. Define Environment Variables**

Set the following environment variables to configure the application execution environment.

```dockerfile
ENV APP_SPECIAL="no"
ENV APP_CMD="/apps/<your_app_name>/install/<your_app_name>.${APP_VERSION}/my_app_executable"
ENV PROCESS_NAME="/apps/<your_app_name>/install/<your_app_name>.${APP_VERSION}/my_app_executable"
ENV APP_DATA_DIR_ARRAY=""
ENV DATA_DIR_ARRAY=""
```

•	APP_SPECIAL: Set to “no” unless special configurations are required.\
•	APP_CMD and PROCESS_NAME: Specify the path to the executable of your application.\
•	APP_DATA_DIR_ARRAY and DATA_DIR_ARRAY: Define directories for application data if applicable.
