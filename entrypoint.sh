#!/bin/sh
set -e

# Default command (assuming container start)
if [ "$1" = 'supervisord' ]; then
	# $DNS_DOMAIN IP config for dnsmasq
	touch /etc/dnsmasq.d/${DNS_DOMAIN}.conf
	# Resolve *.$DNS_DOMAIN to $DNS_IP
	echo "address=/${DNS_DOMAIN}/${IP}" >> /etc/dnsmasq.d/${DNS_DOMAIN}.conf
	# Reverse resolution of $DNS_IP to ${DNS_DOMAIN}
	echo $DNS_IP | awk -v dzone=${DNS_DOMAIN} -F . '{print "ptr-record="$4"."$3"."$2"."$1".in-addr.arpa,"dzone}' >> /etc/dnsmasq.d/${DNS_DOMAIN}.conf
	
	# Turn query loggin on
	if [ "$LOG_QUERIES" = true ]; then
		echo -e '\nlog-queries' >> /etc/dnsmasq.conf
	fi

	# Start supervisord
	exec /usr/bin/supervisord -n
fi

# Any other command (assuming container already running)
exec "$@"
