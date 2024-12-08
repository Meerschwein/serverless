# Deplyment

script: ./deploy.sh

needs:
    - docker
    - gke (with auth plugin)
    - kubectl
    - java8

# Load test script

scipt: ./load_test.sh
(needs to be deployed first)

needs:
    - k6


If you want to run the load test by using the k6 cloud solution, follow the instructions at line 38 in the `load_test.sh` script

---

# Presentation

https://docs.google.com/presentation/d/1cNitf75sppO0yID8YlrjtWJhYXWziODkK0s4aF_t9FA/edit?usp=sharing