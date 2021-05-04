#!/bin/sh

# disable go modules
export GOPATH=""

# disable cgo
export CGO_ENABLED=0

set -e
set -x

# linux
GOOS=linux GOARCH=arm   go build -o release/linux/arm/drone-runner-nomad-podman
