import yaml

# List of paths to YAML files
yaml_files = [
    "./ftgo-application/deployment/kubernetes/stateful-services/ftgo-dynamodb-local.yml",
    "./ftgo-application/deployment/kubernetes/stateful-services/ftgo-kafka-deployment.yml",
    "./ftgo-application/deployment/kubernetes/stateful-services/ftgo-mysql-deployment.yml",
    "./ftgo-application/deployment/kubernetes/stateful-services/ftgo-zookeeper-deployment.yml",

    "./ftgo-application/ftgo-accounting-service/src/deployment/kubernetes/ftgo-accounting-service.yml",
    "./ftgo-application/ftgo-api-gateway/src/deployment/kubernetes/ftgo-api-gateway.yml",
    "./ftgo-application/ftgo-consumer-service/src/deployment/kubernetes/ftgo-consumer-service.yml",
    "./ftgo-application/ftgo-kitchen-service/src/deployment/kubernetes/ftgo-kitchen-service.yml",
    "./ftgo-application/ftgo-order-history-service/src/deployment/kubernetes/ftgo-order-history-service.yml",
    "./ftgo-application/ftgo-order-service/src/deployment/kubernetes/ftgo-order-service.yml",
    "./ftgo-application/ftgo-restaurant-service/src/deployment/kubernetes/ftgo-restaurant-service.yml",


]

# Function to update a StatefulSet yaml
def update_yaml(yaml_content):
    updated_yaml_content = []
    for doc in yaml_content:
        if doc is None:
            continue

        if doc.get("kind") == "StatefulSet" or doc.get("kind") == "Deployment":
            # Update apiVersion
            if doc.get("apiVersion") == "apps/v1beta1" or doc.get("apiVersion") == "extensions/v1beta1":
                doc["apiVersion"] = "apps/v1"

            # Add selector if missing
            if "spec" in doc: # and "selector" not in doc["spec"]:
                if "template" in doc["spec"] and "metadata" in doc["spec"]["template"] and "labels" in doc["spec"]["template"]["metadata"]:
                    # Use a direct copy of labels for matchLabels without using anchors
                    doc["spec"]["selector"] = {"matchLabels": dict(doc["spec"]["template"]["metadata"]["labels"])}
        updated_yaml_content.append(doc)
    return updated_yaml_content

# Function to load, update, and save yaml files
def process_yaml_file(file_path):
    with open(file_path, 'r') as f:
        yaml_content = list(yaml.safe_load_all(f))

    # Update the yaml content
    updated_content = update_yaml(yaml_content)

    # Save the updated content back to the file, excluding null documents
    with open(file_path, 'w') as f:
        yaml.dump_all([doc for doc in updated_content if doc is not None], f, default_flow_style=False, sort_keys=False, explicit_start=True)

# Process each YAML file in the list
for file_path in yaml_files:
    process_yaml_file(file_path)
    print(f"Updated: {file_path}")
