#! /usr/bin/env bash

pushd ./ftgo-application
patch -p1 <../use-protoc-binaries.patch
popd
