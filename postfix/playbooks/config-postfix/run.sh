#!/bin/bash
set -e
ansible-playbook ./site.yaml -i ../../inventory/ -e @secrets-file.enc --ask-vault-pass
