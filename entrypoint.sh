#!/bin/sh
set -e

# Default command (assuming container start)
if [ "$1" = 'supervisord' ]; then
	# $DNS_DOMAIN IP config for dnsmasq
	domain_conf="/etc/dnsmasq.d/${DNS_DOMAIN}.conf"
	echo "Generating configuration in $domain_conf"
	touch $domain_conf
	# Resolve *.$DNS_DOMAIN to $DNS_IP
	echo "address=/${DNS_DOMAIN}/${DNS_IP}" | tee -a $domain_conf
	# Reverse resolution of $DNS_IP to ${DNS_DOMAIN}
	echo $DNS_IP | awk -v dzone=${DNS_DOMAIN} -F . '{print "ptr-record="$4"."$3"."$2"."$1".in-addr.arpa,"dzone}' | tee -a $domain_conf

	# Turn query loggin on
	if [ "$LOG_QUERIES" = true ]; then
		echo -e '\nlog-queries' >> /etc/dnsmasq.conf
	fi

	# Start supervisord
	exec /usr/bin/supervisord -n
fi

# Any other command (assuming container already running)
exec "$@"
