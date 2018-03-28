#!/bin/bash

set -e

if [ -z "$ELASTICSEARCH_HOST" ]; then
  echo "ELASTICSEARCH_HOST must be configured"
  exit 1
fi

exec "$@"
