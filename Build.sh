#!/usr/bin/env bash
set -e
eval "$(cat utils.sh)"

TEST_PB="$(
	cat <<EOF
---
name: test playbook
hosts: localhost
connection: local
gather_facts: no
tasks:
  - name: id
    command: id
  - debug: var=id.stdout
EOF
)"

docker_build() {
	docker build -f Dockerfile
}

setup() {
	export ANSIBLE_PYTHON_INTERPRETER=$(command -v python3)
	if [[ ! -d .v ]]; then
		python3 -m venv .v
		source .v/bin/activate
		pip install pip -U -q
		pip install pyinstaller six ansible -q
	fi

	source .v/bin/activate
}

clean() {
	[[ -d dist ]] && rm -rf dist
	true
}

compile() {
	do_exec "pyinstaller ansible.spec"
	#	while read -r l; do
	#		msg="$(ansi --yellow --italic "$l")"
	#		echo -e "$msg"
	#	done < <(pyinstaller ansible.spec)
	ansi >&2 --magenta --bold "$(find dist -type f)"
	(cd dist && rsync ansible-playbook ansible)
}

do_exec() {
	(
		set +e
		cmd="$@"
		fd_setup
		stdout_file=$(mktemp)
		stderr_file=$(mktemp)
		ec_file=$(mktemp)
		wrap_Exec "$cmd" "$stdout_file" "$stderr_file" "$ec_file"
		ec=$?
		err="$(cat $stderr_file)"
		out="$(cat $stdout_file)"
		return $ec
	)
}

test() {
	while read -r l; do
		msg="$(ansi --green --bold "ANSIBLE> $l")"
		echo -e "$msg"
	done < <(
		./dist/ansible --version
	)
	while read -r l; do
		msg="$(ansi --magenta --bold "ANSIBLE PLAYBOOK> $l")"
		echo -e "$msg"
	done < <(
		./dist/ansible-playbook --version
	)
	./dist/ansible all -i localhost, -c local -m ping
}

debug() {
	echo -e "$(ansi --cyan --bold --bg-black "Test Playbook:  ")\n$(ansi --yellow --italic "$TEST_PB")"
}

common_pre_main() {
	setup
}

prod_main() {
	compile
	debug
	test
	docker_build
}

dev_main() {
	clean
	prod_main
}

main() {
	common_pre_main
	if [[ "$DEV_MODE" == 1 ]]; then
		dev_main
	else
		prod_main
	fi
}

main
