#!/bin/bash

cat <<EOF
Core:
- Linux base: $(lsb_release -a 2> /dev/null | sed -rn 's|^Description:[ \t]+(.+)|\1|p' 2> /dev/null)
- Ansible: $(ansible --version 2> /dev/null | sed -rn 's|^ansible \[core ([0-9.]+)\].*|\1|p' 2> /dev/null)
- AWS CLI: $(aws --version 2> /dev/null | sed -rn 's|^aws-cli/([0-9.]+).*|\1|p' 2> /dev/null)
- Azure CLI: $(az --version 2> /dev/null | sed -rn 's|^azure-cli +([0-9.]+).*|\1|p' 2> /dev/null)
- Github CLI: $(gh --version 2> /dev/null | sed -rn 's|^gh version ([0-9.]+).*|\1|p' 2> /dev/null)
- Google Cloud SDK: $(gcloud --version 2> /dev/null | sed -rn 's|^Google Cloud SDK ([0-9.]+).*|\1|p' 2> /dev/null)
- Kubectl: $(kubectl version --client --short 2> /dev/null | sed -rn 's|^Client Version: v([0-9.]+).*|\1|p' 2> /dev/null)
- Terraform: $(terraform --version 2> /dev/null | sed -rn 's|^Terraform v([0-9.]+).*|\1|p' 2> /dev/null)
- Vault: $(vault --version 2> /dev/null | sed -rn 's|^Vault v([0-9.]+) .*|\1|p' 2> /dev/null)

Extra:
- tfenv: $(tfenv --version 2> /dev/null | sed -rn 's|^tfenv +([0-9.]+).*|\1|p' 2> /dev/null)
- k9s: $(k9s version 2> /dev/null | grep Version | sed -rn 's|^.*Version:.+v([0-9.]+).*|\1|p' 2> /dev/null)
EOF