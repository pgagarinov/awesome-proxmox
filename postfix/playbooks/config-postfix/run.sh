#!/bin/bash
set -e
inventory="../../my-inventory/"
FILE=$1
if [ -f "$FILE" ] || [ -d "$FILE" ]; then
    if [ $FILE != "." ] && [ $FILE != ".." ]; then
        inventory=$FILE
    fi
fi
echo "file [$inventory] is being used as inventory."

ansible-playbook ./site.yaml -i "$inventory" -e @secrets-file.enc --ask-vault-pass
