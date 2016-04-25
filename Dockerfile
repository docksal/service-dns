FROM alpine:3.2

MAINTAINER Leonid Makarov <leonid.makarov@blinkreaction.com>

RUN apk add --update \
	ca-certificates \
	supervisor \
	dnsmasq \

	&& rm -rf /var/cache/apk/*

# Install docker-gen
ENV DOCKER_GEN_VERSION 0.7.0
RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-i386-$DOCKER_GEN_VERSION.tar.gz && \
	tar -C /usr/local/bin -xvzf docker-gen-linux-i386-$DOCKER_GEN_VERSION.tar.gz && \
	rm /docker-gen-linux-i386-$DOCKER_GEN_VERSION.tar.gz

# dnsmasq config dir
RUN mkdir -p /etc/dnsmasq.d && \
	echo -e '\nconf-dir=/etc/dnsmasq.d,.tmpl' >> /etc/dnsmasq.conf

COPY conf/dnsmasq.tmpl /etc/dnsmasq.d/dockergen.tmpl
COPY conf/supervisord.conf /etc/supervisor.d/docker-gen.ini
COPY entrypoint.sh /opt/entrypoint.sh

# Default IP for Drude
ENV DRUDE_IP '192.168.10.10'
ENV LOG_QUERIES false
ENV DOCKER_HOST unix:///var/run/docker.sock

VOLUME /var/run
EXPOSE 53/udp

ENTRYPOINT ["/opt/entrypoint.sh"]

CMD ["supervisord", "-n"]
