#!/bin/bash
cat hosts | while read output
 do
  cat default >> ../filebeat/prospectors.d/"$output".yml
  sed -i -e 's/MOUNTPOINT/'"$output"'/g' ../filebeat/prospectors.d/"$output".yml
 done
