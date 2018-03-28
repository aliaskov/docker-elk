#!/bin/bash

if [ -n "$MAX_INDEX_AGE" ]; then
  /usr/bin/curator_cli --host $ELASTICSEARCH_HOST --port $ELASTICSEARCH_PORT delete_indices --filter_list '[{"filtertype":"age","source":"creation_date","direction":"older","unit":"days","unit_count":'$MAX_INDEX_AGE'},{"filtertype":"pattern","kind":"prefix","value":"logstash"}]' &&
/usr/bin/curator_cli --host $ELASTICSEARCH_HOST --port $ELASTICSEARCH_PORT delete_indices --filter_list '[{"filtertype":"age","source":"creation_date","direction":"older","unit":"days","unit_count":'$MAX_INDEX_AGE'},{"filtertype":"pattern","kind":"prefix","value":"metricbeat"}]' 
else
  echo "Skip purging old indices. MAX_INDEX_AGE is not set."
fi
