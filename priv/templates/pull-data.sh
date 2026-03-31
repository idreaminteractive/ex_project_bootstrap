#!/bin/bash

set -e

INSTANCE=$DB_ADDRESS
LOCAL_PORT=5432   # local PG
DUMP_FILE="/tmp/prod_snapshot.dump"
LOCAL_DB=$DB_NAME


echo $GCP_SA_KEY_B64 | base64 -d > /tmp/gcp-key.json
echo "→ Starting Cloud SQL proxy..."
cloud-sql-proxy $INSTANCE --port 5433 --credentials-file=/tmp/gcp-key.json &
PROXY_PID=$!
trap 'kill ${PROXY_PID}' EXIT
sleep 2  # give it a moment to connect

echo "→ Dumping remote DB..."
export PGPASSWORD=$DB_PULL_PASSWORD
pg_dump -h localhost -p 5433 -U $DB_USER -d $DB_NAME -Fc -f $DUMP_FILE

psql -h localhost -p $LOCAL_PORT -U postgres -d $LOCAL_DB -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

echo "→ Restoring locally..."
pg_restore \
  -h localhost -p $LOCAL_PORT \
  -U postgres -d $LOCAL_DB \
  --no-owner --no-acl \
  $DUMP_FILE

echo "✓ Done. Local DB is now a copy of dev."
