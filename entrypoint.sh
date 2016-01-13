#!/bin/sh
set -e

# Default command (assuming container start)
if [ "$1" = 'supervisord' ]; then
	# $DNS_ZONE IP config for dnsmasq
	touch /etc/dnsmasq.d/${DNS_ZONE}.conf
	# Resolve *.$DNS_ZONE to $DNS_IP
	echo "address=/${DNS_ZONE}/${DNS_IP}" >> /etc/dnsmasq.d/${DNS_ZONE}.conf
	# Reverse resolution of $DNS_IP to ${DNS_ZONE}
	echo $DNS_IP | awk -v dzone=${DNS_ZONE} -F . '{print "ptr-record="$4"."$3"."$2"."$1".in-addr.arpa,"dzone}' >> /etc/dnsmasq.d/${DNS_ZONE}.conf
	
	# Turn query loggin on
	if [ "$LOG_QUERIES" = true ]; then
		echo -e '\nlog-queries' >> /etc/dnsmasq.conf
	fi

	# Start supervisord
	exec /usr/bin/supervisord -n
fi

# Any other command (assuming container already running)
exec "$@"
