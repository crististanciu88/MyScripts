CHATGPT Result:
Simple one-liner (uses `az --version` as requested):

if az --version >/dev/null 2>&1; then echo "az cli is installed"; else sudo yum install -y az-cli; fi

If you prefer a small script with comments:

#!/bin/bash
# check via az --version, install if missing
if az --version >/dev/null 2>&1; then
  echo "az cli is installed"
else
  echo "az cli not found â installing..."
  sudo yum install -y az-cli
fi

Note: on some distributions the package name is azure-cli (not az-cli). If yum can't find az-cli, try sudo yum install -y azure-cli.
PS D:\AzDevOps> 
PS D:\AzDevOps> . 'D:\AzDevOps\deepseekSend.ps1'
DeepSEEK Result:
Here's a simple bash script that checks if Azure CLI is installed and installs it if needed:

```bash
#!/bin/bash

# Check if az cli is installed
if command -v az &> /dev/null; then
    echo "Azure CLI is already installed"
    az --version
else
    echo "Azure CLI not found. Installing..."
    sudo yum install -y azure-cli
fi
```

Or as a one-liner:

```bash
command -v az &> /dev/null && echo "Azure CLI is installed" || (echo "Installing Azure CLI..." && sudo yum install -y azure-cli)
```

**Explanation:**
- `command -v az` checks if the `az` command exists in the system PATH
- `&> /dev/null` redirects both stdout and stderr to suppress output
- If the command exists, it echoes that Azure CLI is installed
- If not, it installs using `yum install azure-cli` (note: the correct package name is `azure-cli`, not `az-cli`)

**Note:** The actual package name for Azure CLI on RHEL/CentOS systems is `azure-cli`, not `az-cli`.
PS D:\AzDevOps> write simple bash lines that will check if az cli is installed by using az --version and if not it will install it using yum install az-cli , else it will echo that az cli is installed
