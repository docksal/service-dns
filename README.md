# DNS Docker image for Docksal

This image(s) is part of the [Docksal](http://docksal.io) image library.

Provides wildcard domain name resolution for local development.

## Features

- Wildcard domain name resolution
- Service discovery for containers

### Wildcard domain name resolution

```bash
$ docker run --name dns -d -e DNS_DOMAIN=docksal -e DNS_IP=192.168.64.100 -e docksal/dns

$ nslookup something.docksal 192.168.64.100
Server:		192.168.64.100
Address:	192.168.64.100#53

Name:	something.docksal
Address: 192.168.64.100
```

Replace `192.168.64.100` with your Docker host IP.

### Service discovery for containers

This image has docker-gen built-in. Whenever containers start or stop the DNS configuration will be updated.

User either the `DNS_NAME` environment variable or the `dns.name` label with your containers to assign them 
an arbitrary domain name. The assigned domain name will be resolved to the container's internal IP address.

```bash
docker run --name dns-test -d -e DNS_NAME=test.mydomain.com busybox top
 
$ nslookup test2.mydomain2.com 192.168.64.100
Server:		192.168.64.100
Address:	192.168.64.100#53

Name:	test2.mydomain2.com
Address: 172.17.0.5
```

```bash
$ docker run --name dns-test2 -d --label dns.name=test2.mydomain2.com busybox top

$ nslookup test.mydomain.com 192.168.64.100
Server:		192.168.64.100
Address:	192.168.64.100#53

Name:	test.mydomain.com
Address: 172.17.0.6
```

Replace `192.168.64.100` with your Docker host IP.

## Debugging 

Launch the container with `LOG_QUERIES=true` to enabled query logging.

```bash
docker run --name dns -d -e DNS_DOMAIN=docksal -e DNS_IP=192.168.100.64 -e LOG_QUERIES=true docksal/dns
```

View logs with `docker logs dns`
