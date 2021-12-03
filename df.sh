#!/usr/bin/env bash
set -eou pipefail
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DISTROS="fedora35 alpine315"
DISTROS="fedora35"
DOCKERFILES="builder ansible linodecli"
DOCKERFILES="ansible"
MODE=${1:-build}
BUILD_ENV=

if [[ -f .envrc ]]; then
  BUILD_ENV="$(
    source .envrc
    while read -r n; do echo -e "--build-arg=${n}=${!n}"; done < <(echo -e "$DOCKERFILE_BUILD_VARS"|tr ' ' '\n')
  )"
fi

build() {
	for DISTRO in $DISTROS; do for DOCKERFILE in $DOCKERFILES; do
		bd="$(pwd)/binaries/$DISTRO"
		sd="$(pwd)/static-binaries/$DISTRO"
		ff=$(mktemp)
		find_cmd="docker run --rm $DISTRO-$DOCKERFILE:latest find /compile/dist /compile/dist-static -type f 2>/dev/null| tee $ff"
		local_dir="[[ -d '$bd' ]] || mkdir -p '$bd'"
		local_dir1="[[ -d '$sd' ]] || mkdir -p '$sd'"
		cmd="docker build -f $DISTRO-$DOCKERFILE.Dockerfile -t $DISTRO-$DOCKERFILE --target $DISTRO-$DOCKERFILE $(echo -e "$BUILD_ENV"|tr '\n' ' ') . && eval $find_cmd && $local_dir &&  $local_dir1"
		ansi >&2 --yellow --italic "$cmd"
		eval "$cmd"
	done; done
}

img_files() {
  _find_cmd='find /compile/dist /compile/dist-static -maxdepth 1 -type f'
	for DISTRO in $DISTROS; do for DOCKERFILE in $DOCKERFILES; do
		find_cmd="docker run --rm $DISTRO-$DOCKERFILE:latest $_find_cmd 2>/dev/null||true"
    eval "$find_cmd"| while read -r f; do
      local_path="./binaries/$DISTRO/$(basename $(dirname $f))/$(basename $f)"
      bn="$(basename $f)"
      chmod_cmd="chmod 0700 $local_path && chown root:root $local_path"
      cat_cmd="docker run --rm $DISTRO-$DOCKERFILE:latest cat $f | pv > $local_path && $chmod_cmd && md5sum $local_path"
      cp_cmd="docker cp \$CID:$f $local_path"
      json="$(cat << EOF
        name=$DISTRO-$DOCKERFILE \
        container_path=$f \
        local_path='$local_path' \
        basename='$bn' \
        distro=$DISTRO \
        cp_cmd='$cp_cmd' \
        cat_cmd='$cat_cmd' \
        find_cmd='$find_cmd' \
        dockerfile=$DISTRO-$DOCKERFILE.Dockerfile \

EOF
)"
      echo -e "$(eval jo $json|jq -Mrc)"
    done
	done; done
}

files(){
  while read -r img f; do
    dd="./binaries/$(echo $img|cut -d'-' -f1)/$(basename $(dirname $f))"
    [[ -d "$dd" ]] || mkdir -p "$dd"
    cid=$(command docker create $img)
		cmd="docker cp $cid:$f $dd/$(basename $f)||true; docker kill $cid 2>/dev/null||true"
		ansi >&2 --yellow --italic "$cmd"
    eval "$cmd"
  done < <(img_files)
}

#build
#cp_img_files
#do_find
#build

eval "$MODE"
