#!/bin/bash
sudo yum update -y && sudo yum install java -y
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cat << EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elastic-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
sudo yum update -y && sudo yum install logstash-oss -y
cat << EOF | sudo tee /etc/logstash/conf.d/logstash.conf
# This input block will listen on port 10514 for logs to come in.
# host should be an IP on the Logstash server.
# codec => "json" indicates that we expect the lines we're receiving to be in JSON format
# type => "rsyslog" is an optional identifier to help identify messaging streams in the pipeline.

input {
  udp {
    port => 514
    type => "syslog"
  }
}

# This is an empty filter block.  You can later add other filters here to further process
# your log lines

filter { }

# This output block will send all events of type "syslog" to Elasticsearch at the configured
# host and port into daily indices of the pattern, "syslog-YYYY.MM.DD"

output {
  if [type] == "syslog" {
    elasticsearch {
      hosts => [ "https://************aeq.eu-west-1.es.amazonaws.com:443" ]
      ilm_enabled => false
      user => "logstash"
      password => "Logstash_p@ssw0rd_********"
    }
  }
}
EOF
sudo sed -i 's/LS_USER=logstash/LS_USER=root/' /etc/logstash/startup.options
sudo sed -i 's/LS_GROUP=logstash/LS_GROUP=root/' /etc/logstash/startup.options
sudo setcap cap_net_bind_service=+epi /usr/lib/jvm/java-11-amazon-corretto.x86_64/bin/java
sudo service logstash start && sudo chkconfig logstash on
/usr/share/logstash/bin/logstash-plugin install logstash-input-syslog
