#!/usr/bin/env bash
set -eou pipefail
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BINARY=${1:-ansible-playbook}

while read -r f; do
	while read -r a; do
		df="xxxxxxx"
		cmd="rsync $f $(dirname $f)/$a"
		ansi >&2 --yellow --italic "$cmd"
		eval "$cmd"
	done < <(./get_binary_aliases.sh "$BINARY")

done < <(find binaries -type f -name "$BINARY")
