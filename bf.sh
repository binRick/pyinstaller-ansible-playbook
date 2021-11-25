#!/usr/bin/env bash
set -eou pipefail
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
VENV_DIR=~/.ansible-build-ansible-binary-venv
SELECTED_DISTROS="${@:-all}"
BASHFUL_ARGS=""

if ! command -v yaml2json >/dev/null; then
	python3 -m venv $VENV_DIR
	python3 -m pip install json2yaml
fi

DISTROS_JSON="$(command cat all_distros.yaml | yaml2json 2>/dev/null | jq '.distros')"
DISTROS="$(json2sh <<<"$DISTROS_JSON" | cut -d= -f2 | sort -u)"

new_distros=./distros.yaml
echo -e "distros: &distros" >$new_distros
added_qty=0
for d in $DISTROS; do
	add=0
	for D in $SELECTED_DISTROS; do
		if [[ "$D" == "all" || "$d" == "$D" ]]; then
			add=1
		fi
	done
	if [[ "$add" == 1 ]]; then
		echo -e "  -\n    - $d" >>$new_distros
		added_qty=$(($added_qty + 1))
	fi
done

if [[ "$added_qty" == 0 ]]; then
	ansi --red --bg-black "No Distro Selected."
	ansi --blue --bg-black --italic "$DISTROS"
	exit 1
fi

ansi >&2 --yellow --bg-black --italic "$(cat $new_distros) :: $added_qty"
cmd="~/bashful/bashful run bf-BuildDockerImage.yaml $BASHFUL_ARGS"

ansi >&2 --yellow --italic "$cmd"
eval "$cmd"
