#!/usr/bin/env bats

# Debugging
teardown() {
	echo
	echo "Output:"
	echo "================================================================"
	echo "${output}"
	echo "================================================================"
}

# Globals
DOCKSAL_IP=192.168.64.100

# To work on a specific test:
# run `export SKIP=1` locally, then comment skip in the test you want to debug

@test "DNS container is up and using the \"${IMAGE}\" image" {
	[[ ${SKIP} == 1 ]] && skip

	run docker ps --filter "name=docksal-dns" --format "{{ .Image }}"
	[[ "$output" =~ "$IMAGE" ]]
	unset output
}

@test ".docksal name resolution" {
	[[ $SKIP == 1 ]] && skip

	# Check .docksal domain resolution via ping
	run ping -c 1 -t 1 anything.docksal
	[[ "${output}" == *"${DOCKSAL_IP}"* ]]
	unset output

	# Check .docksal domain resolution via dig
	run dig @${DOCKSAL_IP} anything.docksal
	[[ "${output}" == *"SERVER: ${DOCKSAL_IP}"* ]]
	[[ "${output}" == *"ANSWER: 1"* ]]
	unset output
}

@test "External name resolution" {
	[[ $SKIP == 1 ]] && skip

	# Real domain
	run ping -c 1 -t 1 www.google.com
	# Use case insensitive comparison (,, modifier), as ping produces different output on different platforms
	[[ "${output,,}" == *"ping www.google.com "* ]]
	[[ "${output,,}" != *"unknown host"* ]]
	unset output

	# Fake domain
	run ping -c 1 -t 1 www.google2.com
	# Use case insensitive comparison (,, modifier), as ping produces different output on different platforms
	[[ "${output,,}" != *"ping www.google2.com "* ]]
	[[ "${output,,}" == *"unknown host"* ]]
	unset output
}
