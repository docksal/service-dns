#!/bin/sh
set -e

# Default command (assuming container start)
if [ "$1" = 'supervisord' ]; then
	# Drude IP config for dnsmasq
	touch /etc/dnsmasq.d/drude.conf
	# Resolve *.drude to $DRUDE_IP
	echo "address=/drude/${DRUDE_IP}" >> /etc/dnsmasq.d/drude.conf
	# Reverse resolution of $DRUDE_IP to 'drude'
	echo $DRUDE_IP | awk -F . '{print "ptr-record="$4"."$3"."$2"."$1".in-addr.arpa,drude"}' >> /etc/dnsmasq.d/drude.conf
	
	# Turn query loggin on
	if [ "$LOG_QUERIES" = true ]; then
		echo -e '\nlog-queries' >> /etc/dnsmasq.conf
	fi

	# Start supervisord
	exec /usr/bin/supervisord -n
fi

# Any other command (assuming container already running)
exec "$@"
