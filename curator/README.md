Elasticsearch Curator helps to curate, or manage (optimize, delete, copy, restore), Elasticsearch indices and snapshots.

How can I check used space in details?

```console
docker exec  elk_curator_1 curator_cli --host elasticsearch --port 9200  show_indices --verbose --header

```
### How long you want to keep the indices?
The data stored can be deleted for certain number of days. You can specify MAX_INDEX_AGE for how long you want to keep the data indices.  

### Copying indices to AWS S3
**Dont forget to create repo in Elasticsearch!**

```console

curl -XPUT 'localhost:9200/_snapshot/old-elasticsearch-indices?pretty' -H 'Content-Type: application/json' -d'
{
  "type": "s3",
  "settings": {
    "bucket": "funke-old-elasticsearch-indices",
    "region": "eu-central-1"
  }
}
'
```

 S3_BUCKET_NAME (has the same name as ES repo) and S3_BUCKET_REGION specifies AWS S3 bucket settings.

OPTIMIZE_EVERY and COPY_TO_S3_AFTER specifies number of days before action.


```yml
curator:
  environment:
    ELASTICSEARCH_HOST: elasticsearch
    ELASTICSEARCH_PORT: 9200
    S3_BUCKET_NAME: old-elasticsearch-indices
    S3_BUCKET_REGION: eu-central-1
    OPTIMIZE_EVERY: 1
    COPY_TO_S3_AFTER: 20
    MAX_INDEX_AGE: 30
```
