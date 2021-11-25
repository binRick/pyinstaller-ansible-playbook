#!/usr/bin/env bash
set -eou pipefail
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BD=$(pwd)
export PATH=$BD/bin:$PATH
new_distros=$BD/distros.yaml
all_distros=$BD/all_distros.yaml
VENV_DIR=~/.ansible-build-ansible-binary-venv
SELECTED_DISTROS="${@:-all}"
BASHFUL_ARGS=""

if ! command -v yaml2json >/dev/null; then
	python3 -m venv $VENV_DIR
	python3 -m pip install json2yaml
fi

DISTROS_JSON="$(command cat $all_distros | yaml2json 2>/dev/null | jq '.all_distros' -Mrc)"
DISTROS="$(json2sh <<<"$DISTROS_JSON" | cut -d= -f2 | sort -u|tr '\n' ' ')"

echo -e '' >$new_distros
added_qty=0
while read -r d; do
	add=0
	for D in $SELECTED_DISTROS; do
		if [[ "$D" == "all" || "$d" == "$D" ]]; then
			add=1
		fi
	done
	if [[ "$add" == 1 ]]; then
		echo -e "- $d" >>$new_distros
		added_qty=$(($added_qty + 1))
	fi
done < <(echo -e "$DISTROS"|tr ' ' '\n'|sort -u|egrep -v '^$')

if [[ "$added_qty" == 0 ]]; then
	ansi --red --bg-black "No Distro Selected."
	ansi --blue --bg-black --italic "$DISTROS"
	exit 1
fi

ansi >&2 --magenta --bg-black --italic "$(cat $new_distros)"
cmd="(cd $BD && ~/bashful/bashful run bf-BuildDockerImage.yaml $BASHFUL_ARGS)"

ansi >&2 --yellow --italic "$cmd"
eval "$cmd"
