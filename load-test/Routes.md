# ftgo-api-gateway
- `/orders/{orderId}` GET
- `/orders` GET
- `/orders` POST
- `/orders` PUT
- `/orders/**` POST
- `/orders/**` PUT
- `/consumers` POST
- `/consumers` PUT

# ftgo-accounting-service [34.55.126.151:8080](http://34.55.126.151:8080/swagger-ui/index.html)
- `/accounts/{accountId}` GET
```
/accounts/1
```

# ftgo-consumer-service [34.121.102.79:8080](http://34.121.102.79:8080/swagger-ui/index.html)
- `/consumers` POST
```
{
  "name": {
    "firstName": "testUserFirst",
    "lastName": "testUserLast"
  }
}
```

- `/consumers/{consumerId}` GET
```
/consumers/1
```

# ftgo-kitchen-service [34.171.5.8:8080](http://34.171.5.8:8080/swagger-ui/index.html)
- `/tickets/{ticketId}/accept` POST
```
34.171.5.8:8080/tickets/0/accept
{
  "readyBy": "2024-12-06T23:32:27.046Z"
}
```
- `/restaurants/{restaurantId}` GET
```
/restaurants/1
```
# ftgo-order-history-service
- `/orders` GET
- `/orders/{orderId}` GET

# ftgo-order-service [34.44.204.145:8080](http://34.44.204.145:8080/swagger-ui/index.html)
- `/orders` POST
- `/orders/{orderId}` GET
- `/{orderId}/cancel` POST
- `/{orderId}/revise` POST
- `/restaurants/{restaurantId}` GET

# ftgo-restaurant-service [34.57.92.65:8080](http://34.57.92.65:8080/swagger-ui/index.html)
- `/restaurants/{restaurantId}` POST
- `/restaurants/{restaurantId}` GET

ftgo-accounting-service      LoadBalancer   34.118.231.94    34.55.126.151   8080:31027/TCP                  34h
ftgo-api-gateway             LoadBalancer   34.118.236.154   34.121.31.249   80:30362/TCP                    34h
ftgo-consumer-service        LoadBalancer   34.118.227.118   34.121.102.79   8080:30472/TCP                  34h
ftgo-dynamodb-local          ClusterIP      34.118.238.162   <none>          8000/TCP                        34h
ftgo-kafka                   ClusterIP      34.118.239.212   <none>          9092/TCP                        34h
ftgo-kitchen-service         LoadBalancer   34.118.239.179   34.171.5.8      8080:31215/TCP                  34h
ftgo-mysql                   ClusterIP      None             <none>          3306/TCP                        34h
ftgo-order-history-service   LoadBalancer   34.118.239.14    34.45.20.105    8080:32415/TCP                  34h
ftgo-order-service           LoadBalancer   34.118.231.152   34.44.204.145   8080:30638/TCP,8081:31777/TCP   34h
ftgo-restaurant-service      LoadBalancer   34.118.229.113   34.57.92.65     8080:30551/TCP                  34h
ftgo-zookeeper               ClusterIP      None             <none>          2181/TCP                        34h
kubernetes                   ClusterIP      34.118.224.1     <none>          443/TCP                         34h

# ./run_all_tests.sh <order_service_ip> <order_service_port> <kitchen_service_ip> <kitchen_service_port> <menu_item_price> <order_id> <consumer_id> <restaurant_id> <restaurant_service_ip> <restaurant_service_port> <consumer_service_ip> <consumer_service_port>
# ./perform-load-test.sh 34.44.204.145 8080 34.171.5.8 8080 100 1 1 1


     execution: local
        script: load_test_files/create_order_test.js
        output: -

     scenarios: (100.00%) 1 scenario, 10 max VUs, 1m0s max duration (incl. graceful stop):
              * default: 10 looping VUs for 30s (gracefulStop: 30s)


     ✓ Consumer created successfully
     ✗ Restaurant created successfully
      ↳  0% — ✓ 0 / ✗ 263
     ✗ Order created successfully
      ↳  0% — ✓ 0 / ✗ 263
     ✗ Order state is APPROVED
      ↳  0% — ✓ 0 / ✗ 263

     checks.........................: 25.00% 263 out of 1052
     data_received..................: 393 kB 13 kB/s
     data_sent......................: 242 kB 7.8 kB/s
     http_req_blocked...............: avg=118.37ms min=0s       med=154.15ms max=171.73ms p(90)=159.93ms p(95)=161.98ms
     http_req_connecting............: avg=118.36ms min=0s       med=154.13ms max=171.73ms p(90)=159.93ms p(95)=161.98ms
     http_req_duration..............: avg=170.83ms min=150.11ms med=167.8ms  max=300.82ms p(90)=186ms    p(95)=197.04ms
       { expected_response:true }...: avg=169.77ms min=161.74ms med=168.06ms max=213.1ms  p(90)=175.91ms p(95)=179.37ms
     http_req_failed................: 75.00% 789 out of 1052
     http_req_receiving.............: avg=1.29ms   min=0s       med=397.95µs max=18.89ms  p(90)=5.38ms   p(95)=5.98ms
     http_req_sending...............: avg=9.91µs   min=0s       med=0s       max=1.01ms   p(90)=0s       p(95)=0s
     http_req_tls_handshaking.......: avg=0s       min=0s       med=0s       max=0s       p(90)=0s       p(95)=0s
     http_req_waiting...............: avg=169.52ms min=150.11ms med=165.84ms max=300.82ms p(90)=184.78ms p(95)=194.56ms
     http_reqs......................: 1052   33.846168/s
     iteration_duration.............: avg=1.15s    min=1.1s     med=1.14s    max=1.45s    p(90)=1.17s    p(95)=1.2s
     iterations.....................: 263    8.461542/s
     vus............................: 3      min=3           max=10
     vus_max........................: 10     min=10          max=10