#!/bin/bash

# Function to check if any service is still in "Pending" state
check_pending() {
  kubectl get services --output=jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' |
  grep -q "Pending"
}

# Wait until no external IP is in "Pending"
echo "Checking for pending external IPs..."
while check_pending; do
  echo "Some services are still pending external IP allocation. Waiting..."
  sleep 5 # Wait for 5 seconds before checking again
done

# Array to store external IPs by service name
declare -A service_ips

# Fetch services and their external IPs
services=$(kubectl get services --output=jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}')

# Populate the associative array with service names and their external IPs
while read -r name ip; do
  if [[ -n "$ip" && "$ip" != "Pending" ]]; then
    service_ips["$name"]="$ip"
  fi
done <<< "$services"

# if [[ -n "$external_ip" ]]; then
#   echo "The external IP of $service_name is: $external_ip"
# else
#   echo "No external IP found for $service_name or the service doesn't exist."
# fi

# Print all service IPs
echo "All service IPs:"
for name in "${!service_ips[@]}"; do
  echo "$name -> ${service_ips[$name]}"
done


TESTFILES_PATH="load_test_files"
SERVICE_PORT="8080"
# Service names
ORDER_SERVICE_NAME="ftgo-order-service"
CONSUMER_SERVICE_NAME="ftgo-consumer-service"
RESTAURANT_SERVICE_NAME="ftgo-restaurant-service"
KITCHEN_SERVICE_NAME="ftgo-kitchen-service"
API_NAME="ftgo-api-gateway"

# Set service URLs and other environment variables
ORDER_SERVICE_IP="${service_ips[$ORDER_SERVICE_NAME]}"
CONSUMER_SERVICE_IP="${service_ips[$CONSUMER_SERVICE_NAME]}"
RESTAURANT_SERVICE_IP="${service_ips[$RESTAURANT_SERVICE_NAME]}"
KITCHEN_SERVICE_IP="${service_ips[$KITCHEN_SERVICE_NAME]}"
API_IP="${service_ips[$API_NAME]}"

ORDER_SERVICE_URL="http://$ORDER_SERVICE_IP:$SERVICE_PORT/orders"
CONSUMER_SERVICE_URL="http://$CONSUMER_SERVICE_IP:$SERVICE_PORT/consumers"
RESTAURANT_SERVICE_URL="http://$RESTAURANT_SERVICE_IP:$SERVICE_PORT/restaurants"
KITCHEN_SERVICE_URL="http://$KITCHEN_SERVICE_IP:$SERVICE_PORT/tickets"
API_URL="http://$API_IP:80/consumers"
MENU_ITEM_PRICE="100.0"
ORDER_ID="1"
CONSUMER_ID="1"
RESTAURANT_ID="2"


# Validate input arguments
# if [ "$#" -ne 8 ]; then
#   echo "Usage: $0"
#   exit 1
# fi

# Log the configuration
echo "Running tests with the following configuration:"
echo "ORDER_SERVICE_URL: $ORDER_SERVICE_URL"
echo "KITCHEN_SERVICE_URL: $KITCHEN_SERVICE_URL"
echo "MENU_ITEM_PRICE: $MENU_ITEM_PRICE"
echo "ORDER_ID: $ORDER_ID"
echo "CONSUMER_ID: $CONSUMER_ID"
echo "RESTAURANT_ID: $RESTAURANT_ID"

# Execute the create order test
echo "Running create_order_test.js..."
k6 $1 $2 -e API_URL="$API_URL" -e RESTAURANT_SERVICE_URL="$RESTAURANT_SERVICE_URL" -e CONSUMER_SERVICE_URL="$CONSUMER_SERVICE_URL" -e ORDER_SERVICE_URL="$ORDER_SERVICE_URL" -e CONSUMER_ID="$CONSUMER_ID" -e RESTAURANT_ID="$RESTAURANT_ID" $TESTFILES_PATH/create_order_test.js
if [ $? -ne 0 ]; then
  echo "create_order_test.js failed. Aborting."
  exit 1
fi

# # Execute the revise order test
# echo "Running revise_order_test.js..."
# k6 run -e ORDER_SERVICE_URL="$ORDER_SERVICE_URL" -e ORDER_ID="$ORDER_ID" -e MENU_ITEM_PRICE="$MENU_ITEM_PRICE" $TESTFILES_PATH/revise_order_test.js
# if [ $? -ne 0 ]; then
#   echo "revise_order_test.js failed. Aborting."
#   exit 1
# fi

# # Execute the accept ticket test
# echo "Running accept_ticket_test.js..."
# k6 run -e KITCHEN_SERVICE_URL="$KITCHEN_SERVICE_URL" -e ORDER_ID="$ORDER_ID" $TESTFILES_PATH/accept_ticket_test.js
# if [ $? -ne 0 ]; then
#   echo "accept_ticket_test.js failed. Aborting."
#   exit 1
# fi

# # Execute the cancel order test
# echo "Running cancel_order_test.js..."
# k6 run -e ORDER_SERVICE_URL="$ORDER_SERVICE_URL" -e ORDER_ID="$ORDER_ID" $TESTFILES_PATH/cancel_order_test.js
# if [ $? -ne 0 ]; then
#   echo "cancel_order_test.js failed. Aborting."
#   exit 1
# fi

echo "All tests executed successfully!"

# k6 run --out cloud test.js

# k6 cloud test.js