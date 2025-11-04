#!/usr/bin/env bash
set -euo pipefail

# Check for az command
if command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) is already installed: $(az --version | head -n1)"
  exit 0
fi

echo "Azure CLI not found. Attempting to install with yum..."
if ! command -v yum >/dev/null 2>&1; then
  echo "yum not found. Cannot install az-cli automatically." >&2
  exit 1
fi

# Install (use sudo if needed)
sudo yum install -y az-cli

# Verify installation
if command -v az >/dev/null 2>&1; then
  echo "az CLI installed: $(az --version | head -n1)"
else
  echo "Installation finished but 'az' command still not found." >&2
  exit 1
fi
