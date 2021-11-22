#!/usr/bin/env bash
set -e
python3 -m venv .v
source .v/bin/activate
pip install pyinstaller six ansible

pyinstaller ansible.spec 
find dist -type f

cd dist
ln -sf ansible-playbook ansible

cd ..


./dist/ansible --version
./dist/ansible-playbook --version

./dist/ansible all -i localhost, -c local -m ping
