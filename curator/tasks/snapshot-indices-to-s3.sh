#!/bin/bash

if [ -n "$COPY_TO_S3_AFTER" ] || [ -n "$S3_BUCKET_NAME" ]; then
  /usr/bin/curator_cli --host $ELASTICSEARCH_HOST --port $ELASTICSEARCH_PORT snapshot --repository $S3_BUCKET_NAME --filter_list '[{"filtertype":"age","source":"creation_date","direction":"older","unit":"days","unit_count":'$COPY_TO_S3_AFTER'},{"filtertype":"pattern","kind":"prefix","value":"logstash"}]'
else
  echo "Skip snapshotting old indices. COPY_TO_S3_AFTER or S3_BUCKET_NAME is not set."
fi



# curl -XPUT 'localhost:9200/_snapshot/funke-old-elasticsearch-indices?pretty' -H 'Content-Type: application/json' -d'
# {
#   "type": "s3",
#   "settings": {
#     "bucket": "old-elasticsearch-indices",
#     "region": "eu-central-1"
#   }
# }
# '
