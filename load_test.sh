#! /usr/bin/env bash

set -e -u -o pipefail
set -x

kubectl apply -f "./load-test/load_test_services/ftgo-accounting-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-api-gateway.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-consumer-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-kitchen-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-order-history-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-order-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-restaurant-service.yml"

waitUntilPodRunning() {
    POD_NAME=$1

    until kubectl get pods | grep Running | grep -q $POD_NAME; do
        echo "Waiting for pod $POD_NAME to be running..."
        sleep 3
    done
}

waitUntilPodRunning "ftgo-accounting-service"
waitUntilPodRunning "ftgo-api-gateway"
waitUntilPodRunning "ftgo-consumer-service"
waitUntilPodRunning "ftgo-kitchen-service"
waitUntilPodRunning "ftgo-order-history-service"
waitUntilPodRunning "ftgo-order-service"
waitUntilPodRunning "ftgo-restaurant-service"

pushd ./load-test

# 20 minutes, 100 VUs

./perform-load-test.sh run

popd

echo "Done"
