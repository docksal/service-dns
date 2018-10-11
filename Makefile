-include env_make

SHELL = /bin/bash
VERSION ?= dev

REPO = docksal/dns
NAME = docksal-dns

.EXPORT_ALL_VARIABLES:

.PHONY: build test push shell run start stop logs debug clean release

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
	@make exec-it -e CMD=bash

# This is the only place where fin is used/necessary
start:
	IMAGE_DNS=${REPO}:${VERSION} fin system reset dns

stop:
	docker stop ${NAME}

logs:
	docker logs ${NAME}

logs-follow:
	docker logs -f ${NAME}

clean:
	docker rm -vf ${NAME}

debug: build start logs-follow

release:
	@scripts/release.sh

default: build
