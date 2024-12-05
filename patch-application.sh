#! /usr/bin/env bash

# uncomment load balancer
sed ./ftgo-application/ftgo-api-gateway/src/deployment/kubernetes/ftgo-api-gateway.yml \
    -i -e 's/#  type: LoadBalancer/  type: LoadBalancer/g'

python update-yaml.py

cp ./ftgo-accounting-service.yml ./ftgo-application/ftgo-accounting-service/src/deployment/kubernetes/ftgo-accounting-service.yml

pushd ./ftgo-application
patch -p1 <../use-protoc-binaries.patch
popd
