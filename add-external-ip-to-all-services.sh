#! /usr/bin/env bash

set -e -u -o pipefail

for file in ./services/*.yml; do
    sed 's/ClusterIP/LoadBalancer/g' $file >./load-test/load_test_services/$(basename $file)
done
