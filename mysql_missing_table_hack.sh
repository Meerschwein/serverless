#! /usr/bin/env bash

set -e -u -o pipefail

MYSQL_POD_NAME=$(kubectl get pods -l role=ftgo-mysql -o jsonpath='{.items[0].metadata.name}')
MYSQL_DATABASE="eventuate"
MYSQL_USER="root"
MYSQL_PASSWORD="rootpassword"

SQL_SCRIPT=$(
    cat <<EOF
CREATE TABLE message (
    id VARCHAR(255) PRIMARY KEY,
    destination VARCHAR(1000) NOT NULL,
    headers VARCHAR(1000) NOT NULL,
    payload VARCHAR(1000) NOT NULL,
    published SMALLINT DEFAULT 0,
    message_partition SMALLINT,
    creation_time BIGINT
);
CREATE TABLE events (
    event_id VARCHAR(255) PRIMARY KEY,
    event_type VARCHAR(255) NOT NULL,
    event_data TEXT NOT NULL,
    entity_type VARCHAR(255) NOT NULL,
    entity_id VARCHAR(255) NOT NULL,
    triggering_event VARCHAR(255),
    metadata JSON,
    published BOOLEAN DEFAULT FALSE
);
EOF
)

kubectl exec -i "$MYSQL_POD_NAME" -- mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "$SQL_SCRIPT" "$MYSQL_DATABASE"
