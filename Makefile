-include env_make

SHELL = /bin/bash
VERSION ?= dev

REPO = docksal/dns
NAME = docksal-dns
DOCKSAL_IP=192.168.64.100

.EXPORT_ALL_VARIABLES:

.PHONY: build exec test push shell run start stop logs debug clean release

build:
	docker build -t ${REPO}:${VERSION} .

test:
	IMAGE=${REPO}:${VERSION} bats tests/test.bats

push:
	docker push ${REPO}:${VERSION}

exec:
	@docker exec ${NAME} ${CMD}

exec-it:
	@docker exec -it ${NAME} ${CMD}

shell:
	@make exec-it -e CMD=sh

run: clean
	docker run --rm -it -e DNS_DOMAIN=docksal -e DNS_IP=${DOCKSAL_IP} ${REPO}:${VERSION} sh

# This is the only place where fin is used/necessary
start:
	IMAGE_DNS=${REPO}:${VERSION} fin system reset dns

stop:
	docker stop ${NAME}

logs:
	docker logs ${NAME}

logs-follow:
	docker logs -f ${NAME}

show-config:
	make exec -e CMD="cat /etc/dnsmasq.d/docksal.conf"

debug: build start logs-follow

release:
	@scripts/release.sh

clean:
	docker rm -vf ${NAME} || true

default: build
