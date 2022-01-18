# Multicloud CLI Docker image

[![release](https://github.com/alvsanand/cloudnative-docker-cli/actions/workflows/release.yaml/badge.svg)](https://github.com/alvsanand/cloudnative-docker-cli/actions/workflows/release.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

The goal is to create a full feature but lightweight Docker image with several cloud native tools that helps its use in computer where installation of software is forbidden or complex.

## Tools

What tools are included and ready to use:

- Common software: curl, git, jq, vi, zip...
- [Ansible](https://www.ansible.com/)
- [AWS CLI](https://aws.amazon.com/en/cli/)
- [Azure CLI](https://docs.microsoft.com/cli/azure)
- [Google Cloud SDK](https://cloud.google.com/sdk/gcloud)
- [Kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
- [Terraform](https://www.terraform.io/) and [https://github.com/tfutils/tfenv](https://github.com/tfutils/tfenv).
- [Vault](https://www.vaultproject.io/)

## How to use it

### Launch the CLI

You just have to execute a Docker ```run```:

    ```bash
    docker run -it --rm ghcr.io/alvsanand/cloudnative-docker-cli:latest
    ```

> The `--rm` flag will completely destroy the container and its data on exit.

If you want to execute it as a daemon and USER_HOME mounted in ```/data/home```:

- Create the container as daemon:

      ```bash
      # Windows (CMD)
      docker run --restart=always -d ^
        -v "%USERPROFILE%:/data/home" ^
        --name cloudnative-docker-cli ^
        ghcr.io/alvsanand/cloudnative-docker-cli:latest ^
        bash -c "while true; do sleep 10000; done"

      # Unix
      docker run --restart=always -d \
        -v "$HOME:/data/home" -u $(stat -c "%u:%g" $HOME) \
        --name cloudnative-docker-cli \
        ghcr.io/alvsanand/cloudnative-docker-cli:latest \
        bash -c "while true; do sleep 10000; done"
      ```

- Execute a shell inside the container:

      ```bash
      # Windows (CMD)
      FOR /F "tokens=*" %g IN ('docker ps -aq --filter "name=cloudnative-docker-cli"') do (SET DOCKER_ID=%g)

      docker exec -it %DOCKER_ID% bash

      # Unix
      docker exec -it $(docker ps -aq --filter name=cloudnative-docker-cli) bash
      ```

- If needed, delete the pod:

      ```bash
      # Windows (CMD)
      FOR /F "tokens=*" %g IN ('docker ps -aq --filter "name=cloudnative-docker-cli"') do (SET DOCKER_ID=%g)

      docker rm -f %DOCKER_ID%

      # Unix
      docker rm -f $(docker ps -aq --filter name=cloudnative-docker-cli)
      ```

> A Docker container may be due to its stateless nature, so be sure to backup data frequently.

Additionally, you can add more parameters to Docker in order to add configuration to the commands. All will dependes of the tool. For example:

- Set proxy:

      ```bash
      docker run -it --rm -e "HTTP_PROXY=SOME_PROXY_URL" -e "HTTPS_PROXY=SOME_PROXY_URL" -e "NO_PROXY=127.0.0.1,localhost,docker.host.internal" -v ${PWD}:/workspace ghcr.io/alvsanand/cloudnative-docker-cli:latest
      ```

- Set AWS credentials using environment variables:

      ```bash
      docker run -it --rm -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" -e "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" -v ${PWD}:/workspace ghcr.io/alvsanand/cloudnative-docker-cli:latest
      ```

- Set AWS credentials using aws config:

      ```bash
      # Windows (CMD)
      docker run -it --rm  -v "%USERPROFILE%\\.aws:/home/cloudnative-docker-cli/.aws" workspace ghcr.io/alvsanand/cloudnative-docker-cli:latest
      
      # Unix
      docker run -it --rm  -v "$HOME/.aws:/home/cloudnative-docker-cli/.aws" workspace ghcr.io/alvsanand/cloudnative-docker-cli:latest
      ```

Finally, there is a [Powershell script](https://github.com/alvsanand/cloudnative-docker-cli/blob/main/scripts/cloudnative-docker-cli-installer.ps1) that could be used a templated to:

- Run cloudnative-docker-cli as a daemon.
- Mount several volumes by default.
- Create a Windows Terminal Profile.
- Using ```--restore``` parameter can restore to a default version of cloudnative-docker-cli.

### Terraform

In order to change the version, execute the following command:

    ```bash
    TF_VERSION=SOME_VERSION # Example: TF_VERSION=0.12

    sudo tfenv install latest:$TF_VERSION && tfenv use latest:$TF_VERSION
    ```
