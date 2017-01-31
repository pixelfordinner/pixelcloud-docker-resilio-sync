FROM alpine:3.4
MAINTAINER Karl Fathi <karl@pixelfordinner.com>

ENV LANG C.UTF-8

ENV RESILIO_VERSION 2.4.4
LABEL com.resilio.version="2.4.4"

RUN apk add --no-cache \
  su-exec \
	tar \
	libc6-compat

RUN  mkdir -p \
 /lib64 && \
 ln /lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

RUN set -x \
	&& addgroup -g 82 -S www-data \
	&& adduser -u 82 -D -S -G www-data www-data

ADD https://download-cdn.resilio.com/$RESILIO_VERSION/linux-x64/resilio-sync_x64.tar.gz /tmp/sync.tgz

RUN tar -xf /tmp/sync.tgz -C /usr/bin rslsync && rm -f /tmp/sync.tgz

COPY data/sync.conf.default /etc/

# Entrypoint
COPY data/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8888
EXPOSE 55555

CMD ["entrypoint.sh"]
