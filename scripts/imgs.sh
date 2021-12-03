#!/usr/bin/env bash
set -e
docker images|grep '^localhost/'|cut -d' ' -f1|sort -u
