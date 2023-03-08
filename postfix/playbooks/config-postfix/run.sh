#!/bin/bash
set -e

inventory="../../my-inventory/"
FOLDER=$1
if [ -f "$FOLDER" ] || [ -d "$FOLDER" ]; then
    if [ $FOLDER != "." ] && [ $FOLDER != ".." ]; then
        inventory=$FOLDER
    fi
fi
echo "folder [$inventory] is being used as inventory."

ansible-playbook ./site.yaml -i "$inventory" -e @secrets-file.enc --ask-vault-pass
