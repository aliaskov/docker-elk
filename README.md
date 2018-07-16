# Docker ELK stack

![Big picture](https://github.com/aliaskov/docker-elk/blob/master/stack.jpg)

Run the latest version of the ELK (Elasticsearch, Logstash, Kibana) stack with Docker and Docker Compose. Additionally, filebeat and metricbeat (log and system metrics shippers) included.

It will give you the ability to analyze any data set by using the searching/aggregation capabilities of Elasticsearch
and the visualization power of Kibana, logs delivered by filebeat and prepared/transformed by logstash.
Traefik is used as a HTTP reverse proxy. It uses AWS Route53 and free let's encrypt ssl certs to give true https.
Based on the official Docker images:

* [elasticsearch](https://github.com/elastic/elasticsearch-docker) 6.2.2-oss
* [logstash](https://github.com/elastic/logstash-docker) 6.2.2-oss
* [kibana](https://github.com/elastic/kibana-docker) 6.2.4-oss
* [filebeat](https://github.com/elastic/beats-docker) 6.2.2
* [metricbeat](https://github.com/elastic/beats-docker) 6.2.2
* [elastalert](https://elastalert.readthedocs.io/en/latest/) 
* [curator](https://www.elastic.co/guide/en/elasticsearch/client/curator/current/about.html)  based on alpine+pip+curator
* [traefik](https://github.com/containous/traefik) latest 


## Contents
1. [About ELK](#about-elk)
2. [Getting started](#getting-started)
   * [Bringing up the stack](#bringing-up-the-stack)
   * [Initial setup](#initial-setup)
3. [Configuration](#configuration)
   * [How can I tune the Kibana configuration?](#how-can-i-tune-the-kibana-configuration)
   * [How can I tune the Logstash configuration?](#how-can-i-tune-the-logstash-configuration)
   * [How can I tune the Beats configuration?](#how-can-i-tune-the-beats-configuration)
   * [How can I tune the Elasticsearch configuration?](#how-can-i-tune-the-elasticsearch-configuration)
   * [How can I scale out the Elasticsearch cluster?](#how-can-i-scale-up-the-elasticsearch-cluster)
4. [Storage](#storage)
   * [How can I persist Elasticsearch data?](#how-can-i-persist-elasticsearch-data)
   * [Rexray](#rexray)
5. [Extensibility](#extensibility)
   * [How can I add plugins?](#how-can-i-add-plugins)
   * [How can I enable the provided extensions?](#how-can-i-enable-the-provided-extensions)
6. [JVM tuning](#jvm-tuning)
   * [How can I specify the amount of memory used by a service?](#how-can-i-specify-the-amount-of-memory-used-by-a-service)
   * [How can I enable a remote JMX connection to a service?](#how-can-i-enable-a-remote-jmx-connection-to-a-service)
7. [Elasticsearch cleanup and optimization with Curator](#curator)
  * [What is Curator?](#what-is-curator)
  * [How long you want to keep the indices?](#how-long-you-want-to-keep-the-indices)
  * [Copying indices to AWS S3](#copying-indices-to-aws-s3)
8. [Traefik](#traefik)



### About ELK

## What is ELK?

"ELK" is the acronym for three open source projects: Elasticsearch, Logstash, and Kibana. Elasticsearch is a search and analytics engine. Logstash is a server‑side data processing pipeline that ingests data from multiple sources simultaneously, transforms it, and then sends it to a "stash" like Elasticsearch. Kibana lets users visualize data with charts and graphs in Elasticsearch.

## Usage

### Bringing up the stack

**Note**: In case you switched branch or updated a base image - you may need to run `docker-compose build` first

Start the ELK stack using `docker-compose` in background (detached mode):


```console
$ docker-compose up -d
```

Give  Elasticsearch and Kibana a few seconds to initialize, then access the Kibana web UI by hitting 5601 port
[http://localhost:5601](http://localhost:5601) with a web browser.

By default, the stack exposes the following ports:
* 5000: Logstash TCP input.
* 9200: Elasticsearch HTTP
* 9300: Elasticsearch TCP transport
* 5601: Kibana

Now that the stack is running, logstash waits filebeat to send data.
Look at filebeat logs, wait for harvester to find logs.

## Initial setup

### Default Kibana index pattern creation

When Kibana launches for the first time, it is not configured with any index pattern.

#### Via the Kibana web UI

**NOTE**: You need to inject data into Logstash before being able to configure a Logstash index pattern via the Kibana web
UI. Then all you have to do is hit the *Create* button.

Refer to [Connect Kibana with
Elasticsearch](https://www.elastic.co/guide/en/kibana/current/connect-to-elasticsearch.html) for detailed instructions
about the index pattern configuration.

#### On the command line

Create an index pattern via the Kibana API:

```console
$ curl -XPOST -D- 'http://localhost:5601/api/saved_objects/index-pattern' \
    -H 'Content-Type: application/json' \
    -H 'kbn-version: 6.2.2' \
    -d '{"attributes":{"title":"logstash-*","timeFieldName":"@timestamp"}}'
```

The created pattern will automatically be marked as the default index pattern as soon as the Kibana UI is opened for the first time.

## Configuration

**NOTE**: Configuration is not dynamically reloaded, you will need to restart the stack after any change in the
configuration of a component.

### How can I tune the Kibana configuration?

The Kibana default configuration is stored in `kibana/config/kibana.yml`.

It is also possible to map the entire `config` directory instead of a single file.

### How can I tune the Logstash configuration?

The Logstash configuration is stored in `logstash/config/logstash.yml`.

It is also possible to map the entire `config` directory instead of a single file, however you must be aware that
Logstash will be expecting a
[`log4j2.properties`](https://github.com/elastic/logstash-docker/tree/master/build/logstash/config) file for its own
logging.
### How can I tune the Beats (filebeat and metricbeat) configuration?

Filebeat takes logs from sshfs mounts and push them to Elasticsearch.
Simple bash script, extensions/sshfs-mount.sh mounts all servers' /opt/escenic directory  on /mounts. After this stack mounts all /mounts on filebeats container.
Filebeat container uses /mounts to grab logs.
Logs paths listed in prospectors.d/ yml files per log type.

Metricbeat sends system metrics ( cpu, load, Per CPU core stats, IO stats etc) to Elasticsearch every 10 seconds. Also, to get docker stats from /var/run/docker.sock on host need to modify permissions and mount it inside metricbeat container.

```console
setfacl -m u:1000:rw /var/run/docker.sock
```
From docker-compose:
```yml
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Both Filebeat and Metricbeat configuration files are copied during docker container creation, so rebuild is needed.

**NOTE:**  --no-cache flag is needed during  rebuilding of the container after chmod and chown!

### How can I tune the Elasticsearch configuration?

The Elasticsearch configuration is stored in `elasticsearch/config/elasticsearch.yml`.

You can also specify the options you want to override directly via environment variables:

```yml
elasticsearch:

  environment:
    network.host: "_non_loopback_"
    cluster.name: "my-cluster"
```

### How can I scale out the Elasticsearch cluster?

Follow the instructions from the Wiki: [Scaling out
Elasticsearch](https://github.com/deviantony/docker-elk/wiki/Elasticsearch-cluster)

## Storage

### How can I persist Elasticsearch data?

The data stored in Elasticsearch will be persisted after container reboot but not after container removal.

In order to persist Elasticsearch data even after removing the Elasticsearch container, you'll have to mount a volume on
your Docker host. Update the `elasticsearch` service declaration to:

```yml
elasticsearch:

  volumes:
    - /path/to/storage:/usr/share/elasticsearch/data
```

This will store Elasticsearch data inside `/path/to/storage`.

**NOTE:** beware of these OS-specific considerations:
* **Linux:** the [unprivileged `elasticsearch` user][esuser] is used within the Elasticsearch image, therefore the
  mounted data directory must be owned by the uid `1000`.
* **macOS:** the default Docker for Mac configuration allows mounting files from `/Users/`, `/Volumes/`, `/private/`,
  and `/tmp` exclusively. Follow the instructions from the [documentation][macmounts] to add more locations.

[esuser]: https://github.com/elastic/elasticsearch-docker/blob/016bcc9db1dd97ecd0ff60c1290e7fa9142f8ddd/templates/Dockerfile.j2#L22
[macmounts]: https://docs.docker.com/docker-for-mac/osxfs/


### Rexray

Rexray is used for storage management.
Installation could be found here:
[Installation]: https://rexray.readthedocs.io/en/stable/

```console
docker plugicurl -sSL https://rexray.io/install | sh -s -- stable
curl -sSL https://rexray.io/install | sh -s -- stable
sudo systemctl start rexray
```
or via docker container rexray/ebs:latest

**Dont forget about AWS credentials and IAM role to give rexray permissions to create and modify Volumes.**

## Extensibility

### How can I add plugins?

To add plugins to any ELK component you have to:

1. Add a `RUN` statement to the corresponding `Dockerfile` (eg. `RUN logstash-plugin install logstash-filter-json`)
2. Add the associated plugin code configuration to the service configuration (eg. Logstash input/output)
3. Rebuild the images using the `docker-compose build` command

### How can I enable the provided extensions?

A few extensions are available inside the [`extensions`](extensions) directory. These extensions provide features which
are not part of the standard Elastic stack, but can be used to enrich it with extra integrations.

The documentation for these extensions is provided inside each individual subdirectory, on a per-extension basis. Some
of them require manual changes to the default ELK configuration.

## JVM tuning

### How can I specify the amount of memory used by a service?

By default, both Elasticsearch and Logstash start with [1/4 of the total host
memory](https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gctuning/parallel.html#default_heap_size) allocated to
the JVM Heap Size.

The startup scripts for Elasticsearch and Logstash can append extra JVM options from the value of an environment
variable, allowing the user to adjust the amount of memory that can be used by each component:

| Service       | Environment variable |
|---------------|----------------------|
| Elasticsearch | ES_JAVA_OPTS         |
| Logstash      | LS_JAVA_OPTS         |

To accomodate environments where memory is scarce (Docker for Mac has only 2 GB available by default), the Heap Size
allocation is capped by default to 256MB per service in the `docker-compose.yml` file. If you want to override the
default JVM configuration, edit the matching environment variable(s) in the `docker-compose.yml` file.

For example, to increase the maximum JVM Heap Size for Logstash:

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Xmx1g -Xms1g"
```

### How can I enable a remote JMX connection to a service?

As for the Java Heap memory (see above), you can specify JVM options to enable JMX and map the JMX port on the docker
host.

Update the `{ES,LS}_JAVA_OPTS` environment variable with the following content (I've mapped the JMX service on the port
18080, you can change that). Do not forget to update the `-Djava.rmi.server.hostname` option with the IP address of your
Docker host (replace **DOCKER_HOST_IP**):

```yml
logstash:

  environment:
    LS_JAVA_OPTS: "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=18080 -Dcom.sun.management.jmxremote.rmi.port=18080 -Djava.rmi.server.hostname=DOCKER_HOST_IP -Dcom.sun.management.jmxremote.local.only=false"
```


## Curator

### What is Curator?
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

curl -XPUT 'localhost:9200/_snapshot/funke-old-elasticsearch-indices?pretty' -H 'Content-Type: application/json' -d'
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
    S3_BUCKET_NAME: funke-old-elasticsearch-indices
    S3_BUCKET_REGION: eu-central-1
    OPTIMIZE_EVERY: 1
    COPY_TO_S3_AFTER: 20
    MAX_INDEX_AGE: 30
```

### Traefik

Træfik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy.
**Don't forget to change the domain name in docker-compose file, after you create Route53 DNS entry!**
[here is the explanation and example](https://docs.traefik.io/user-guide/docker-and-lets-encrypt/)
