#!/usr/bin/env bats

# Debugging
teardown () {
	echo
	echo "Output:"
	echo "================================================================"
	echo "${output}"
	echo "================================================================"
}

# Checks container health status (if available)
# @param $1 container id/name
_healthcheck ()
{
	local health_status
	health_status=$(${DOCKER} inspect --format='{{json .State.Health.Status}}' "$1" 2>/dev/null)

	# Wait for 5s then exit with 0 if a container does not have a health status property
	# Necessary for backward compatibility with images that do not support health checks
	if [[ $? != 0 ]]; then
		echo "Waiting 10s for container to start..."
		sleep 10
		return 0
	fi

	# If it does, check the status
	echo $health_status | grep '"healthy"' >/dev/null 2>&1
}

# Waits for containers to become healthy
_healthcheck_wait ()
{
	# Wait for cli to become ready by watching its health status
	local container_name="${1}"
	local delay=1
	local timeout=30
	local elapsed=0

	until _healthcheck "$container_name"; do
		echo "Waiting for $container_name to become ready..."
		sleep "$delay";

		# Give the container 30s to become ready
		elapsed=$((elapsed + delay))
		if ((elapsed > timeout)); then
			echo "$container_name heathcheck failed"
			exit 1
		fi
	done

	return 0
}

# To work on a specific test:
# run `export SKIP=1` locally, then comment skip in the test you want to debug

@test "${NAME} container is up and using the \"${IMAGE}\" image" {
	[[ ${SKIP} == 1 ]] && skip

	run _healthcheck_wait ${NAME}
	unset output

	# Using "bash -c" here to expand ${DOCKER} (in case it's more that a single word).
	# Without bats run returns "command not found"
	run bash -c "${DOCKER} ps --filter 'name=${NAME}' --format '{{ .Image }}'"
	[[ "$output" =~ "${IMAGE}" ]]
	unset output
}

@test ".docksal name resolution via docksal-dns" {
	[[ $SKIP == 1 ]] && skip

	# Check .docksal domain resolution via dig
	run nslookup -timeout=1 anything.docksal ${DOCKSAL_IP}
	[[ ${status} == 0 ]]
	unset output
}

@test "External name resolution via docksal-dns" {
	[[ $SKIP == 1 ]] && skip

	# Real domain
	run nslookup -timeout=1 docksal.site ${DOCKSAL_IP}
	[[ ${status} == 0 ]]
	unset output

	# Fake domain
	run nslookup -timeout=1 docksal.xyz ${DOCKSAL_IP}
	[[ ${status} != 0 ]]
	unset output
}
