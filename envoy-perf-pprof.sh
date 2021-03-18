#!/usr/bin/env bash

ENVOY_VERSION=$1
FILE="$(cd "$(dirname "$2")" && pwd -P)/$(basename "$2")"
[ -z "$ENVOY_VERSION" ] || [ -z "$FILE" ] && echo "usage: ./envoy-perf-pprof.sh <envoy-version> <perf-record-file>" && exit 1

docker build -t envoy-perf-pprof --build-arg ENVOY_VERSION=$ENVOY_VERSION .
docker run -p 8888:8888 -v $FILE:/root/envoy.perf envoy-perf-pprof /root/envoy.perf

