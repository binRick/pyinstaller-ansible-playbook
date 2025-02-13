#!/usr/bin/env bash
set -eou pipefail
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DISTROS="${DISTROS:-fedora35 alpine315 fedora34}"
DOCKERFILES="${DOCKERFILES:-builder ansible yaml2json}"
MODE=${1:-main}
BUILD_ENV=
command -v json2yaml || pip3 install json2yaml

if [[ -f .envrc ]]; then
	BUILD_ENV="$(
		source .envrc
		while read -r n; do echo -e "--build-arg=${n}=${!n}"; done < <(echo -e "$DOCKERFILE_BUILD_VARS" | tr ' ' '\n')
	)"
fi

build() {
	for DISTRO in $DISTROS; do for DOCKERFILE in $DOCKERFILES; do
		ff=$(mktemp)
		find_cmd="docker run --rm $DISTRO-$DOCKERFILE:latest find /compile/dist /compile/dist-static -type f 2>/dev/null| tee $ff"
		cmd="docker build -f $DISTRO-$DOCKERFILE.Dockerfile -t $DISTRO-$DOCKERFILE --target $DISTRO-$DOCKERFILE $(echo -e "$BUILD_ENV" | tr '\n' ' ') . && eval $find_cmd"
		ansi >&2 --yellow --italic "$cmd"
		eval "$cmd"
	done; done
}

cp_files() {
	while read -r J; do
		cmd="$(echo -e "$J" | jq -Mrc '.cp_cmd')"
		ansi >&2 --yellow --italic "$cmd"
		eval "$cmd"
	done < <(img_files)
}

img_files() {
	_find_cmd='find /compile/dist /compile/dist-static -maxdepth 1 -type f'
	for DISTRO in $DISTROS; do for DOCKERFILE in $DOCKERFILES; do
		find_cmd="docker run --rm $DISTRO-$DOCKERFILE:latest $_find_cmd 2>/dev/null||true"
		eval "$find_cmd" | while read -r f; do
			local_path="./binaries/$DISTRO/$(basename $(dirname $f))/$(basename $f)"
			bn="$(basename $f)"
			dn="$(dirname $local_path)"
			[[ -d "$dn" ]] || mkdir -p "$dn"
			chmod_cmd="chmod 0700 $local_path && chown root:root $local_path"
			cat_cmd="docker run --rm $DISTRO-$DOCKERFILE:latest cat $f | pv > $local_path && $chmod_cmd && md5sum $local_path"
			cp_cmd="docker run --rm -v \$(pwd)/$dn:/H $DISTRO-$DOCKERFILE:latest cp $f /H/."
			json="$(
				cat <<EOF
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
			echo -e "$(eval jo $json | jq -Mrc)"
		done
	done; done
}

cp_binary_aliases(){
  ./cp_binary_aliases.sh
}

main() {
	set +e
	build
	img_files
	cp_files
  cp_binary_aliases
}
eval "$MODE"
