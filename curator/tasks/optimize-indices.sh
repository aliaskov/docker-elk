#!/bin/bash

curator_cli --host $ELASTICSEARCH_HOST --port $ELASTICSEARCH_PORT forcemerge --max_num_segments 1 --filter_list '[{"filtertype":"age","source":"creation_date","direction":"older","unit":"days","unit_count":'$OPTIMIZE_EVERY'},{"filtertype":"pattern","kind":"prefix","value":"logstash"}]'
