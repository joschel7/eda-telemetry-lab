#!/bin/bash

function install-uv {
    # error if uv is not in the path
    if ! command -v uv &> /dev/null;
    then
        echo "Installing uv";
        curl -LsSf https://astral.sh/uv/install.sh | sh
    fi

}

# install uv and clab-connector
install-uv
uv tool install git+https://github.com/eda-labs/clab-connector.git

# Define the configuration file path
PROM_CONFIG_FILE="configs/prometheus/prometheus.yml"

# Check if the configuration file exists
if [[ ! -f "$PROM_CONFIG_FILE" ]]; then
  echo "Error: $PROM_CONFIG_FILE not found."
  exit 1
fi

# Fetch EDA ext domain name from engine config
EDA_IP=$(uv run ./scripts/get_eda_ip.py)


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

# save EDA API address to a file
EDA_EXT_DOMAIN_NAME=$(kubectl -n eda-system get engineconfigs/engine-config -o jsonpath={.spec.cluster.external.domainName})
EDA_HTTPS_PORT=$(kubectl -n eda-system get engineconfigs/engine-config -o jsonpath={.spec.cluster.external.httpsPort})
echo "$EDA_EXT_DOMAIN_NAME:$EDA_HTTPS_PORT" > .eda_api_address