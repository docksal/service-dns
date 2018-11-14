#!/bin/sh

DEBUG=${DEBUG:-0}
# Turn debugging ON when cli is started in the service mode
if [ "$1" == "dnsmasq" ]; then DEBUG=1; fi

# Print a debug message if debug mode is on
# @param message
echo_debug ()
{
	[[ "$DEBUG" != 0 ]] && echo "$(date +"%F %H:%M:%S") | $@"
}

# Generate dnsmasq config for the domain
domain_conf="/etc/dnsmasq.d/${DNS_DOMAIN}.conf"
echo_debug "Generating configuration in ${domain_conf}"
touch ${domain_conf}
# Resolve *.$DNS_DOMAIN to $DNS_IP
echo "address=/${DNS_DOMAIN}/${DNS_IP}" | tee -a ${domain_conf} > /dev/null
# Reverse resolution of $DNS_IP to ${DNS_DOMAIN}
echo ${DNS_IP} | awk -v dzone=${DNS_DOMAIN} -F . '{print "ptr-record="$4"."$3"."$2"."$1".in-addr.arpa,"dzone}' | tee -a ${domain_conf} > /dev/null

# Turn query logging on if requested
if [ "${LOG_QUERIES}" = true ]; then
	echo -e '\nlog-queries' >> /etc/dnsmasq.conf
fi

# Execute passed CMD arguments
echo_debug "Passing execution to: $*"
# Service mode
if [ "$1" = "dnsmasq" ]; then
	exec dnsmasq -d -k
# Command mode
else
	exec "$@"
fi
