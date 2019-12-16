# Allow using a different docker binary
DOCKER ?= docker

SHELL = /bin/bash

ifeq ($(VERSION),)
    VERSION = dev
    LATEST_VERSION = $(VERSION)
endif

BUILD_TAG ?= $(VERSION)
REPO = docksal/dns
NAME = docksal-dns
DOCKSAL_IP=192.168.64.100

.EXPORT_ALL_VARIABLES:

.PHONY: build exec test push shell run start stop logs debug clean release

build:
	${DOCKER} build -t ${REPO}:${BUILD_TAG} .

test:
	IMAGE=${REPO}:${BUILD_TAG} bats tests/test.bats

push:
	${DOCKER} push ${REPO}:${BUILD_TAG}

exec:
	@${DOCKER} exec ${NAME} ${CMD}

exec-it:
	@${DOCKER} exec -it ${NAME} ${CMD}

shell:
	@make exec-it -e CMD=sh

run: clean
	${DOCKER} run --rm -it -e DNS_DOMAIN=docksal -e DNS_IP=${DOCKSAL_IP} ${REPO}:${BUILD_TAG} sh

# This is the only place where fin is used/necessary
start:
	IMAGE_DNS=${REPO}:${BUILD_TAG} fin system reset dns

stop:
	${DOCKER} stop ${NAME}

logs:
	${DOCKER} logs ${NAME}

logs-follow:
	${DOCKER} logs -f ${NAME}

show-config:
	make exec -e CMD="cat /etc/dnsmasq.d/docksal.conf"

debug: build start logs-follow

release:
	@scripts/docker-push.sh

clean:
	${DOCKER} rm -vf ${NAME} || true

default: build
