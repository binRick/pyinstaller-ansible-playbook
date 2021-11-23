get_distro_colors(){
 cat << EOF
fedora magenta  
ubuntu red  
alpine cyan
centos green
EOF
}
distro_color(){
  d="$1"
  c="yellow"
  while read -r _d _c; do
    [[ "$d" == "$_d" ]] && { echo "$_c" && return; }
  done < <(get_distro_colors)
  echo -e "$c"
}
fd_setup() {
	exec 3>&1 4>&2 5>&2
}
loggerForStdout() {
	local x
	while IFS= read -r x; do
		[[ "$x" == "" ]] && continue
		x="$(ansi --green --bold "$x")"
		printf "STDOUT\t%s\n" "$x"
	done >&4
}
loggerForExitCode() {
	local x
	local cmd="$1"
	while IFS= read -r x; do printf "EXIT_CODE\t'$cmd' => \t%d\n" "$x"; done >&5
}
loggerForStderr() {
	local x
	while IFS= read -r x; do
		[[ "$x" == "" ]] && continue
		x="$(ansi --magenta --bold "$x")"
		printf "STDERR\t%s\n" "$x"
	done >&2
}

wrap_Exec() {
	local cmd="$1"
	local stdout_file="$2"
	local stderr_file="$3"
	local ec_file="$4"
	local cp=$$
	( (
		stdbuf -oL -eL env $(command -v bash) --norc --noprofile +x +e -c "$cmd"
		{ echo -e "$?" | tee $ec_file >/dev/null; }
	) | tee $stdout_file | loggerForStdout) 2>&1 | tee $stderr_file | loggerForStderr
	cat $ec_file | loggerForExitCode "$cmd" >/dev/null
	return $(cat $ec_file)
}

demo() {
	fd_setup

	stdout_file=$(mktemp)
	stderr_file=$(mktemp)
	ec_file=$(mktemp)
	cmd="ls /a && ls /b; ls /c; ls /22;find /|head -n10;ls /11;"
	cmd="ls /a"
	cmd="ls /"
	cmd="ls /;ls /a && ls /b; ls /c; ls /22;find /|head -n10;ls /11;"
	wrap_Exec \
		"$cmd" "$stdout_file" "$stderr_file" "$ec_file"
	ec=$?
	err="$(cat $stderr_file)"
	out="$(cat $stdout_file)"

	ansi --yellow "$cmd"
	ansi --red "$err"
	ansi --green "$out"
	ansi --cyan "$ec"
	exit $ec
}
