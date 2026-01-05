#!/bin/sh

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Paths
KEY_FILE1="$SCRIPT_DIR/../keys/wgkey1.txt.enc"
KEY_FILE2="$SCRIPT_DIR/../keys/wgkey2.txt.enc"
VPN_CONF="$SCRIPT_DIR/../vpn/cornbypassusca5.conf"

read -s -p "Enter Key Decryption password: " WG_KEY_PASSWORD
echo

if [ -z "WG_KEY_PASSWORD" ]; then
  echo "ERROR: No Password entered"
  exit 1
fi

echo "Decrypt Private Key"
TEMP_PRIV_KEY=$(mktemp)

openssl aes-256-cbc -d -a -in "$KEY_FILE1" \
  -out "$TEMP_PRIV_KEY" \
  -pass pass:"$WG_KEY_PASSWORD"

WG_PRIVATE_KEY=$(cat "$TEMP_PRIV_KEY")

echo "Decrypt Public Key"
TEMP_PUB_KEY=$(mktemp)

openssl aes-256-cbc -d -a -in "$KEY_FILE2" \
  -out "$TEMP_PUB_KEY" \
  -pass pass:"$WG_KEY_PASSWORD"

WG_PUBLIC_KEY=$(cat "$TEMP_PUB_KEY")

echo "Inserting Keys into VPN config"
TEMP_CONF=$(mktemp)

sed "s|The_Empire_Strikes_Back|$WG_PRIVATE_KEY|g; s|Revenge_Of_The_Sith|$WG_PUBLIC_KEY|g" \
  "$VPN_CONF" > "$TEMP_CONF"
mv "$TEMP_CONF" "$VPN_CONF"

echo "Deleting TEMP files"
rm "$TEMP_PRIV_KEY"
rm "$TEMP_PUB_KEY"

echo "Importing VPN Config.."
nmcli connection import type wireguard file "$VPN_CONF"
