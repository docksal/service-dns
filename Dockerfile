FROM alpine:3.8

RUN set -xe; \
	apk add --update --no-cache \
		dnsmasq \
	; \
	rm -rf /var/cache/apk/*

# Set strict-order
RUN sed -i '/strict-order/s/^#//g' /etc/dnsmasq.conf

COPY docker-entrypoint.sh /usr/local/bin
COPY healthcheck.sh /opt/healthcheck.sh

# Default domain and IP for wildcard query resolution
ENV DNS_DOMAIN 'docksal'
ENV DNS_IP '192.168.64.100'
ENV LOG_QUERIES false

EXPOSE 53/udp

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["dnsmasq"]

# Health check script
HEALTHCHECK --interval=5s --timeout=1s --retries=12 CMD ["/opt/healthcheck.sh"]
