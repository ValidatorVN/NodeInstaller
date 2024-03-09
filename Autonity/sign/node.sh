#!/bin/bash

install_expect() {
    sudo apt install -y expect
}

# Check if expect is installed, if not, install it
if ! command -v expect &>/dev/null; then
    echo "Expect is not installed. Installing..."
    install_expect
fi

KEYSTORE_DIR="$HOME/piccadilly-keystore"
DATA_DIR="$HOME/autonity-client/autonity-chaindata"

echo -e "\n ----- Begin get SIGNATURE OF MESSAGE...\n"
sleep 1

# Prompt the user to choose an option
echo "Choose an option:"
echo "1. Sign message for onboard validator task"
echo "2. Sign message for open the door task"
read -p "Enter your choice (1 or 2): " choice

# Set MSG variable based on user's choice
if [[ $choice == 1 ]]; then
    MSG="validator onboarded"
elif [[ $choice == 2 ]]; then
    MSG="public rpc"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

sleep 1

read -r -p "Enter wallet password: " WALLET_PASSWORD

sudo rm -rf $KEYSTORE_DIR/node.priv $KEYSTORE_DIR/node.key

head -c 64 "$DATA_DIR/autonity/autonitykeys" > "$KEYSTORE_DIR/node.priv"

# Use expect to automate password entry
expect << EOF
spawn aut account import-private-key -s $KEYSTORE_DIR -k "$KEYSTORE_DIR/node.key" "$KEYSTORE_DIR/node.priv"
expect "Password for new account:"
send "$WALLET_PASSWORD\r"
expect "Confirm account password:"
send "$WALLET_PASSWORD\r"
expect eof
EOF

echo -e "\n\nSign command: aut account sign-message -p $WALLET_PASSWORD -k $KEYSTORE_DIR/node.key \"$MSG\""

signature_message=$(aut account sign-message -p $WALLET_PASSWORD -k "$KEYSTORE_DIR/node.key" "$MSG")

admin_enode=$(aut node info | jq -r '.admin_enode')

echo -e "\n======== ENODE OF YOUR VALIDATOR NODE ========\n"
echo -e "\e[1m\e[32m$admin_enode \e[0m"
echo -e "\n===============================================\n"

echo -e "\n======== SIGNATURE OF MESSAGE VALIDATOR ONBOARDED ========\n"
echo -e "\e[1m\e[32m$signature_message \e[0m"
echo -e "\n==========================================================\n"

echo -e "\e[1m\e[32m GOOD LUCK ! \e[0m"
