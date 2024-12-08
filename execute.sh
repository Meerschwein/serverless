#! /usr/bin/env bash

update kubectl
kubectl apply -f "./stateful/ftgo-db-secret.yml"kubectl apply -f "./stateful/ftgo-mysql-deployment.yml"
kubectl apply -f "./stateful/ftgo-zookeeper-deployment.yml"
kubectl apply -f "./stateful/ftgo-kafka-deployment.yml"
kubectl apply -f "./stateful/ftgo-dynamodb-local.yml"

PODS=("ftgo-mysql-0" "ftgo-kafka-0" "ftgo-zookeeper-0" "ftgo-dynamodb-local")

bash ./ftgo-application/deployment/kubernetes/scripts/kubernetes-wait-for-ready-pods.sh $PODS

kubectl apply -f "./load-test/load_test_services/ftgo-accounting-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-api-gateway.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-consumer-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-kitchen-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-order-history-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-order-service.yml"
kubectl apply -f "./load-test/load_test_services/ftgo-restaurant-service.yml"

kubectl get services
kubectl get pods

pushd ./load-test

# 20 minutes, 100 VUs

./perform-load-test.sh run

popd

echo "Done"