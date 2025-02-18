#!/bin/bash

IMAGE_NAME="code-encryptor"
CONTAINER_NAME="code-encryptor-builder"
Y4_VERSION="0.4"

podman build .
podman push `podman build -q .` docker.io/lrobot/code-encryptor:$Y4_VERSION
echo "podman run --rm -it lrobot/code-encryptor:0.4 java -jar /app.jar"

