#!/bin/bash

# Define the configuration file path
PROM_CONFIG_FILE="configs/prometheus/prometheus.yml"

# Check if the configuration file exists
if [[ ! -f "$PROM_CONFIG_FILE" ]]; then
  echo "Error: $PROM_CONFIG_FILE not found."
  exit 1
fi

# Fetch EDA ext domain name from engine config
if command -v uv &> /dev/null; then
    EDA_IP=$(uv run ./scripts/get_eda_ip.py)
else
    EDA_IP=$(python ./scripts/get_eda_ip.py)
fi

# Ensure input is not empty
if [[ -z "$EDA_IP" ]]; then
  echo "No input provided. Exiting."
  exit 1
fi

# Replace the IP/FQDN in the targets line.
# This sed command looks for a line starting with optional spaces, a dash, then "targets: ['" followed by any characters until the next single quote,
# and replaces that content with the provided EDA_IP.
sed -i.bak -E "s/(^[[:space:]]*- targets: \[')[^']+('].*)/\1${EDA_IP}\2/" "$PROM_CONFIG_FILE"

echo "Updated target to '$EDA_IP' in $PROM_CONFIG_FILE"