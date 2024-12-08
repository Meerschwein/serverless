#! /usr/bin/env bash

set -e -x -o pipefail

GCP_PROJECT_ID="ftgo-microservice-project"
GCP_REGION="us-central1"
GCP_CLUSTER_NAME="ftgo-k8s-cluster"
GCP_ZONE="us-central1-a"

pushd ./ftgo-application

# Create a Google Cloud project
# if ! gcloud projects list --filter="name=$GCP_PROJECT_ID" | grep -q $GCP_PROJECT_ID; then
#     gcloud projects create $GCP_PROJECT_ID
# fi

# Set the current project
gcloud config set project $GCP_PROJECT_ID

# Enable required Google Cloud services
# SERVICES=("container.googleapis.com" "cloudbuild.googleapis.com" "artifactregistry.googleapis.com")
# for SERVICE in "${SERVICES[@]}"; do
#     gcloud services enable $SERVICE
# done

# Create Google Kubernetes Engine cluster
if ! gcloud container clusters list --zone=$GCP_ZONE | grep -q $GCP_CLUSTER_NAME; then
    echo "Creating GKE cluster $GCP_CLUSTER_NAME..."
    gcloud container clusters create $GCP_CLUSTER_NAME \
        --zone=$GCP_ZONE \
        --num-nodes=3 \
        --machine-type=e2-standard-4
fi

# Authenticate with GKE cluster
gcloud container clusters get-credentials $GCP_CLUSTER_NAME --zone $GCP_ZONE

# Set up Google Artifact Registry to host Docker images
REGISTRY_NAME="ftgo-docker-registry"
REGISTRY_LOCATION="$GCP_REGION"
REGISTRY_REPO="docker"

if ! gcloud artifacts repositories list --location=$REGISTRY_LOCATION | grep -q $REGISTRY_NAME; then
    gcloud artifacts repositories create $REGISTRY_NAME \
        --repository-format=$REGISTRY_REPO \
        --location=$REGISTRY_LOCATION
fi

# Configure Docker to push to Google Artifact Registry
gcloud auth configure-docker $GCP_REGION-docker.pkg.dev

./gradlew assemble

SERVICES=(
    "ftgo-accounting-service"
    "ftgo-api-gateway"
    "ftgo-consumer-service"
    "ftgo-delivery-service"
    "ftgo-kitchen-service"
    "ftgo-order-history-service"
    "ftgo-order-service"
    "ftgo-restaurant-service"
)

for SERVICE in "${SERVICES[@]}"; do
    IMAGE_URI="$GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$REGISTRY_NAME/$SERVICE"
    docker build --build-arg baseImageVersion=BUILD-17 -t $IMAGE_URI -f ./$SERVICE/Dockerfile ./$SERVICE
    docker push $IMAGE_URI
done

popd

waitUntilPodRunning() {
    POD_NAME=$1

    until kubectl get pods | grep Running | grep -q $POD_NAME; do
        echo "Waiting for pod $POD_NAME to be running..."
        sleep 3
    done
}

kubectl apply -f "./stateful/ftgo-db-secret.yml"

kubectl apply -f "./stateful/ftgo-zookeeper-deployment.yml"
kubectl apply -f "./stateful/ftgo-mysql-deployment.yml"
kubectl apply -f "./stateful/ftgo-dynamodb-local.yml"

waitUntilPodRunning "ftgo-zookeeper-0"

kubectl apply -f "./stateful/ftgo-kafka-deployment.yml"

waitUntilPodRunning "ftgo-kafka-0"
waitUntilPodRunning "ftgo-mysql-0"

bash ./mkmessagetable.sh

kubectl apply -f "./stateful/ftgo-cdc-service.yml"

waitUntilPodRunning "ftgo-cdc-service"
waitUntilPodRunning "ftgo-dynamodb-local"

kubectl apply -f "./stateful/ftgo-dynamodb-init.yml"

kubectl apply -f "./services/ftgo-accounting-service.yml"
kubectl apply -f "./services/ftgo-consumer-service.yml"
kubectl apply -f "./services/ftgo-delivery-service.yml"
kubectl apply -f "./services/ftgo-kitchen-service.yml"
kubectl apply -f "./services/ftgo-order-history-service.yml"
kubectl apply -f "./services/ftgo-order-service.yml"
kubectl apply -f "./services/ftgo-restaurant-service.yml"

waitUntilPodRunning "ftgo-accounting-service"
waitUntilPodRunning "ftgo-consumer-service"
waitUntilPodRunning "ftgo-delivery-service"
waitUntilPodRunning "ftgo-kitchen-service"
waitUntilPodRunning "ftgo-order-history-service"
waitUntilPodRunning "ftgo-order-service"
waitUntilPodRunning "ftgo-restaurant-service"

kubectl apply -f "./services/ftgo-api-gateway.yml"

waitUntilPodRunning "ftgo-api-gateway"
