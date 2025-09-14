#!/bin/bash

# Display usage
usage() {
    echo "$0 [-encrypt|-decrypt]"
    echo "  -encrypt    Encrypt the yml files in the project that contains the key |encrypt: true|"
    echo "  -decrypt    Decrypt all the yml files that has \$ANSIBLE_VAULT in their header"
    exit 1
}

if [ "$#" -ne 1 ]; then
    usage
fi

case $1 in 
    -encrypt)
            echo "[manage-sensitive-vars.sh]: Encrypting sensitive files..."
        for file in $(find . -type f -name "*.yml"); do
            if grep -q "encrypt: true" "$file"; then
                echo "[manage-sensitive-vars.sh]: Encrypting $file"
                ansible-vault encrypt $file --vault-password-file ./hooks/vault-password --encrypt-vault-id default
            fi
        done
        ;;
    -decrypt)
        echo "[manage-sensitive-vars.sh]: Decrypting sensitive files..."
        for file in $(find . -type f -name "*.yml"); do
            if grep -q "\$ANSIBLE_VAULT" "$file"; then
                echo "[manage-sensitive-vars.sh]: Decrypting $file"
                ansible-vault decrypt $file --vault-password-file ./hooks/vault-password
            fi
        done
        ;;
esac