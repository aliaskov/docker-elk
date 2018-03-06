# https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html
FROM docker.elastic.co/beats/filebeat:6.2.2
COPY config/filebeat.yml /usr/share/filebeat/filebeat.yml
USER root
RUN chown filebeat /usr/share/filebeat/filebeat.yml
RUN chmod go-w /usr/share/filebeat/filebeat.yml
USER filebeat
