#!/bin/bash
set -e

inventory="../../my-inventory/"
INVENTORY_PATH=$1
if [ -f "$INVENTORY_PATH" ] || [ -d "$INVENTORY_PATH" ]; then
    if [ $INVENTORY_PATH != "." ] && [ $INVENTORY_PATH != ".." ]; then
        inventory=$INVENTORY_PATH
    fi
fi
echo "inventory given by path [$inventory] will be used"

ansible-playbook ./site.yaml -i "$inventory" -e @secrets-file.enc --ask-vault-pass
