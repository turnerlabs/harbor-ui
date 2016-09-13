#!/bin/bash
USER_ID=${USER_ID}
GRAPH_FILE=${GRAPH_FILE:=/tmp/graphs.ids}
echo "Deleting all embeds not attached to dashboards with USERID=$USER_ID"
./node_modules/dogapi/bin/dogapi embed getall | jq --arg USER_ID ${USER_ID}  ".embedded_graphs | map(select(.shared_by == $USER_ID)) | map(select(.dash_url == null))" | jq -r .[].embed_id > $GRAPH_FILE

while IFS='' read -r line || [[ -n "$line" ]]; do
    ./node_modules/dogapi/bin/dogapi embed revoke $line
done < "$GRAPH_FILE"
