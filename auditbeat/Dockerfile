FROM docker.elastic.co/beats/auditbeat:6.2.2
COPY config/auditbeat.yml /usr/share/auditbeat/auditbeat.yml
USER root
RUN chown auditbeat /usr/share/auditbeat/auditbeat.yml
RUN chmod go-w /usr/share/auditbeat/auditbeat.yml
USER auditbeat
