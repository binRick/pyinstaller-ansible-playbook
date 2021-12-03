#!/usr/bin/env bash
set -eou pipefail
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DISTROS="fedora35 alpine315"
DOCKERFILES="builder ansible linodecli"
MODE=${1:-build}

build() {
	for DISTRO in $DISTROS; do for DOCKERFILE in $DOCKERFILES; do
		bd="$(pwd)/binaries/$DISTRO"
		sd="$(pwd)/static-binaries/$DISTRO"
		ff=$(mktemp)
		find_cmd="docker run --rm $DISTRO-$DOCKERFILE:latest find /compile/dist /compile/dist-static -type f 2>/dev/null| tee $ff"
		local_dir="[[ -d '$bd' ]] || mkdir -p '$bd'"
		local_dir1="[[ -d '$sd' ]] || mkdir -p '$sd'"
		cmd="docker build -f $DISTRO-$DOCKERFILE.Dockerfile -t $DISTRO-$DOCKERFILE --target $DISTRO-$DOCKERFILE . && eval $find_cmd && $local_dir &&  $local_dir1"
		ansi >&2 --yellow --italic "$cmd"
		#eval "$cmd"
	done; done
}

img_files() {
  find_cmd='find /compile/dist /compile/dist-static -maxdepth 1 -type f'
	for DISTRO in $DISTROS; do for DOCKERFILE in $DOCKERFILES; do
		cmd="docker run --rm $DISTRO-$DOCKERFILE:latest $find_cmd 2>/dev/null|xargs -I % echo -e $DISTRO-$DOCKERFILE\ %"
		ansi >&2 --yellow --italic "$cmd"
    #eval "$cmd"
	done; done
}

cp_img_files(){
  while read -r img f; do
    dd="./binaries/$(echo $img|cut -d'-' -f1)/$(basename $(dirname $f))"
    [[ -d "$dd" ]] || mkdir -p "$dd"
    cid=$(command docker create $img)
		cmd="docker cp $cid:$f $dd/$(basename $f)||true; docker kill $cid 2>/dev/null||true"
		ansi >&2 --yellow --italic "$cmd"
  done < <(img_files 2>&1|bleach_text|bash)
}

#do_find
#build

eval "$MODE"
