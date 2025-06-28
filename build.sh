#!/bin/bash

# Parse only valid `ENV VAR=value` lines and convert to --build-arg VAR=value
ARGS=$(grep '^ENV ' .env | sed 's/^ENV /--build-arg /')

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  $ARGS \
  -t dewab/k8s-cli-toolkit:latest \
  --push .