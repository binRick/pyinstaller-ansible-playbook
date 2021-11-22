#!/usr/bin/env bash
set -e
python3 -m venv .v
source .v/bin/activate
pip install pyinstaller six ansible
pyinstaller ansible.spec 
