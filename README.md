# DNS Docker image for Docksal

This image(s) is part of the [Docksal](http://docksal.io) image library.

Provides wildcard domain name resolution for local development.

## Usage

```bash
$ docker run --name dns -d -e DNS_DOMAIN=docksal -e DNS_IP=192.168.64.100 docksal/dns

$ nslookup something.docksal 192.168.64.100
Server:		192.168.64.100
Address:	192.168.64.100#53

Name:	something.docksal
Address: 192.168.64.100
```

Replace `192.168.64.100` with your Docker host IP.

## Debugging 

Launch the container with `LOG_QUERIES=true` to enabled query logging.

```bash
docker run --name dns -d -e DNS_DOMAIN=docksal -e DNS_IP=192.168.100.64 -e LOG_QUERIES=true docksal/dns
```

View logs with `docker logs dns`
