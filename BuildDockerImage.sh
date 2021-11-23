#!/usr/bin/env bash
set -e
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export PATH=$(pwd)/bin:$PATH
eval "$(cat utils.sh)"

exec 3>&2

distros() { ls Dockerfile.* | cut -d'.' -f2 | sort -u; }

build_distro() {
	DISTRO="$1"
	DOCKERPATH=$(pwd)
	DOCKERFILE=$(pwd)/Dockerfile.$DISTRO
	DOCKER_ARGS="-t $DISTRO"
	DOCKER_MODE=build
	cmd="docker $DOCKER_MODE $DOCKER_ARGS -f $DOCKERFILE $DOCKERPATH"
	msg="$(ansi --yellow --italic "$cmd")"
	echo >&3 -e "$cmd"
	eval "$cmd"
}

build_distros() {
	while read -r distro; do
		ansi --cyan "$distro"
		while read -r l; do
			msg="$(ansi --$(distro_color $distro) --bold "$distro")> $(ansi --yellow --bg-black --italic "$l")"
			echo >&3 -e "$msg"
		done < <(build_distro "$distro") &
	done < <(distros)
	wait
}

build_distros
