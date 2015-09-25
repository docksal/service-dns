FROM alpine:3.2

MAINTAINER Leonid Makarov <leonid.makarov@blinkreaction.com>

RUN apk add --update \
	ca-certificates \
	supervisor \
	dnsmasq \

	&& rm -rf /var/cache/apk/*

ENV DOCKER_GEN_VERSION 0.4.1

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-i386-$DOCKER_GEN_VERSION.tar.gz && \
	tar -C /usr/local/bin -xvzf docker-gen-linux-i386-$DOCKER_GEN_VERSION.tar.gz && \
	rm /docker-gen-linux-i386-$DOCKER_GEN_VERSION.tar.gz

ENV DOCKER_HOST unix:///var/run/docker.sock

COPY conf/dnsmasq.tmpl /etc/dnsmasq.tmpl
COPY conf/supervisord.conf /etc/supervisor.d/docker-gen.ini

VOLUME /var/run
EXPOSE 53/udp

CMD ["/usr/bin/supervisord", "-n"]
