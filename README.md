# Multicloud CLI Docker image

[![release](https://github.com/alvsanand/cloudnative-docker-cli/actions/workflows/release.yml/badge.svg)](https://github.com/alvsanand/cloudnative-docker-cli/actions/workflows/release.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Docker Pulls](https://img.shields.io/docker/pulls/alvsanand/cloudnative-docker-cli.svg)](https://hub.docker.com/r/alvsanand/cloudnative-docker-cli/)

The goal is to create a **minimalist** and **lightweight** image with several Cloud providers that helps its use in computer where installation of software is forbidden or complex.

## What's inside ?
Tools included:

* Common software: curl, git, jq, vi, zip...
* [Ansible](https://www.ansible.com/)
* [AWS CLI](https://aws.amazon.com/en/cli/)
* [Azure CLI](https://docs.microsoft.com/cli/azure)
* [Google Cloud SDK](https://cloud.google.com/sdk/gcloud)
* [Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
* [Terraform](https://www.terraform.io/) and [https://github.com/tfutils/tfenv](https://github.com/tfutils/tfenv).
* [Vault](https://www.vaultproject.io/)

## How to use it

### Launch the CLI

- AWS:

```bash

if [[ -d "$HOME/.aws"]]; then
    "-v $HOME/.aws:/workspace/.azure"
fi

docker container run -it --rm -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v ${PWD}:/workspace ghcr.io/alvsanand/cloudnative-docker-cli:latest
```

> The `--rm` flag will completely destroy the container and its data on exit.


### Terraform

In order to change the version, execute the following command:

```bash
sudo tfenv use latest:TERRAFORM_MAYOR_VERSION # Example: sudo tfenv use latest:0.12
```