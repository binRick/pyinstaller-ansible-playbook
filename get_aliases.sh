#!/usr/bin/env bash
set -eou pipefail
cd $(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BINARY=${1:-ansible-playbook}

cmd="$(
	cat <<EOF
cat bf-BuildDockerImage.yaml|yaml2json | jq '.["x-reference-data"]["aliases"]' -rM|grep '"'|cut -d'"' -f2|sort -u
EOF
)"

ansi >&2 --yellow --italic "$cmd"
while read -r f; do
	echo -e "$f"
done < <(eval "$cmd")
