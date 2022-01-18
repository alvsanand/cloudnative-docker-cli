#!/bin/bash

# Updates id of the group to mathc host group
if [[ -z "$(getent group $(id -g))" ]]; then
    sudo groupmod -g $(id -g) cloudnative-docker-cli
fi

# Enable autocomplete commands
grep 'kubectl completion' "$HOME/.bashrc" > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then        
    echo "complete -C /usr/local/bin/aws_completer aws" >> ~/.bashrc   
    
    echo "source /usr/local/bin/az.completion.sh" >> ~/.bashrc    
    
    echo "source /usr/local/lib/google-cloud-sdk/completion.bash.inc" >> ~/.bashrc
    
    echo "source <(kubectl completion bash)" >> ~/.bashrc
    echo "alias k=kubectl" >> ~/.bashrc
    echo " complete -F __start_kubectl k" >> ~/.bashrc

    terraform -install-autocomplete
    
    vault -autocomplete-install
fi

exec "$@"