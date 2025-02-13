#!/bin/bash

# Define the configuration file path
CONFIG_FILE="configs/prometheus/prometheus.yml"

# Check if the configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: $CONFIG_FILE not found."
  exit 1
fi

# Prompt the user for the EDA IP/FQDN
read -p "Enter EDA IP/FQDN: " EDA_IP

# Ensure input is not empty
if [[ -z "$EDA_IP" ]]; then
  echo "No input provided. Exiting."
  exit 1
fi

# Replace the IP/FQDN in the targets line.
# This sed command looks for a line starting with optional spaces, a dash, then "targets: ['" followed by any characters until the next single quote,
# and replaces that content with the provided EDA_IP.
sed -i.bak -E "s/(^[[:space:]]*- targets: \[')[^']+('].*)/\1${EDA_IP}\2/" "$CONFIG_FILE"

echo "Updated target to '$EDA_IP' in $CONFIG_FILE"
