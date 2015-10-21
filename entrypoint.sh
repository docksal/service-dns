#!/bin/sh
set -e

# Default command (assuming container start)
if [ "$1" = 'supervisord' ]; then
	# Drude IP config for dnsmasq
	touch /etc/dnsmasq.d/drude.conf
	# Resolve *.drude to $DRUDE_IP
	echo "address=/drude/${DRUDE_IP}" >> /etc/dnsmasq.d/drude.conf
	
	# Start supervisord
	exec /usr/bin/supervisord -n
fi

# Any other command (assuming container already running)
exec "$@"
