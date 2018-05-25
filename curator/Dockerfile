FROM gliderlabs/alpine:3.6

ENV CURATOR_VERSION 5.4.0
ENV TZ=Europe/Berlin
#ENV ELASTICSEARCH_PORT 9200
#ENV MAX_INDEX_AGE 0
#ENV ELASTICSEARCH_HOST elasticsearch

RUN apk --update add tzdata python py-pip bash && pip install --upgrade  elasticsearch-curator==$CURATOR_VERSION
RUN apk add ca-certificates && update-ca-certificates

RUN rm -rf /var/cache/apk/*
ADD docker-entrypoint.sh /
ADD tasks/optimize-indices.sh /etc/periodic/
ADD tasks/purge-old-indices.sh /etc/periodic/
ADD tasks/snapshot-indices-to-s3.sh /etc/periodic/

RUN chmod -R a+x /etc/periodic/*.sh

RUN printf "\n0\t2\t*\t*\t*\t/etc/periodic/purge-old-indices.sh" >> /etc/crontabs/root
RUN printf "\n0\t3\t*\t*\t*\t/etc/periodic/optimize-indices.sh" >> /etc/crontabs/root
RUN printf "\n0\t4\t*\t*\t*\t/etc/periodic/snapshot-indices-to-s3.sh" >> /etc/crontabs/root

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["crond", "-f", "-l", "8"]
