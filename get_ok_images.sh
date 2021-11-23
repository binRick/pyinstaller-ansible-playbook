./docker_test_cmds.sh | xargs -I % -P 5 sh -c "%" | command grep ^OK | cut -d' ' -f2
