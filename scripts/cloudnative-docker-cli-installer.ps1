#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


if ($args[0] -match "--help")  # The term in brackets is a true/false value
{
Write-Output 'Installer for cloudnative-docker-cli and configure a profile in Windows Terminal.

Usage: cloudnative-docker-cli_install_windows_terminal.bat [Options]

Options:
  --restore: Delete current installation'

    Exit 0
}

$WT_CONFIG_FILE="$env:USERPROFILE\AppData\Local\Microsoft\Windows Terminal\settings.json"

# Obtain ID of the container if exists
$DOCKER_ID=(docker ps -aq --filter "name=cloudnative-docker-cli")

if ($args[0] -match "--restore") {
    # Delete container

    if ($DOCKER_ID) {
        Write-Output "Deleting Docker container[$DOCKER_ID]"
        
        docker rm -f $DOCKER_ID

        Start-Sleep -Seconds 1

        Write-Output "Deleted Docker container[$DOCKER_ID]"

        $DOCKER_ID=""
    }
}

# Create container
if (!$DOCKER_ID) {
    Write-Output "Launching Docker container"

    docker pull ghcr.io/alvsanand/cloudnative-docker-cli:latest

    $EXTRA_VOLUMES=""

    if (Test-Path "$env:USERPROFILE\.aws") {
        $EXTRA_VOLUMES="$EXTRA_VOLUMES -v `"/$($env:USERPROFILE.replace('\','/').replace(':',''))/.aws:/home/cloudnative-docker-cli/.aws`""
    }
    
    if (Test-Path "$env:USERPROFILE\.azure") {
        $EXTRA_VOLUMES="$EXTRA_VOLUMES -v `"/$($env:USERPROFILE.replace('\','/').replace(':',''))/.azure:/home/cloudnative-docker-cli/.azure`""
    }
    
    if (Test-Path "$env:USERPROFILE\.kube") {
        $EXTRA_VOLUMES="$EXTRA_VOLUMES -v `"/$($env:USERPROFILE.replace('\','/').replace(':',''))/.kube:/home/cloudnative-docker-cli/.kube`""
    }
    
    if (Test-Path "$env:USERPROFILE\.config\gh") {
        $EXTRA_VOLUMES="$EXTRA_VOLUMES -v `"/$($env:USERPROFILE.replace('\','/').replace(':',''))/.config/gh:/home/cloudnative-docker-cli/.config/gh`""
    }
    
    if (Test-Path "$env:USERPROFILE\.config\gcloud") {
        $EXTRA_VOLUMES="$EXTRA_VOLUMES -v `"/$($env:USERPROFILE.replace('\','/').replace(':',''))/.config/gcloud:/home/cloudnative-docker-cli/.config/gcloud`""
    }    
    
$DOCKER_COMMAND=@"
docker run --restart=always -d ``
    -v "/$($env:USERPROFILE.replace('\','/').replace(':',''))/:/data/home" $EXTRA_VOLUMES ``
    -e "HTTP_PROXY=http://host.docker.internal:8080" ``
    -e "HTTPS_PROXY=http://host.docker.internal:8080" ``
    -e "NO_PROXY=host.docker.internal,localhost,127.0.0.0/8,0.0.0.0,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12" ``
    --name cloudnative-docker-cli ``
    ghcr.io/alvsanand/cloudnative-docker-cli:latest ``
    bash -c "while true; do sleep 10000; done"
"@
    Invoke-expression "$DOCKER_COMMAND"

    Start-Sleep -Seconds 5
    
    $DOCKER_ID=(docker ps -aq --filter "name=cloudnative-docker-cli")

    if (!$DOCKER_ID) {
        Write-Output "Error launching Docker container"
        Exit 1
    }
    
    Write-Output "Launched Docker container[$DOCKER_ID]"

    if (Test-Path $WT_CONFIG_FILE) {
        Write-Output "Configuring Windows Terminal"

        cp "$WT_CONFIG_FILE" "$WT_CONFIG_FILE.bck"
        $CONFIG_DATA = Get-Content "$WT_CONFIG_FILE" -Encoding UTF8
        
        if (Select-String -Path "$WT_CONFIG_FILE" -Pattern "CLOUDNATIVE-DOCKER-CLI") {
            $CONFIG_DATA -replace "docker exec -it (.+) bash", "docker exec -it $DOCKER_ID bash" | Out-File -FilePath "$WT_CONFIG_FILE" -Encoding UTF8

            Write-Output "Updated profile[CLOUDNATIVE-DOCKER-CLI] of Windows Terminal configuration[$WT_CONFIG_FILE]"
        } else {
            $UUID=[guid]::NewGuid().ToString()
            $EmojiIcon = [System.Convert]::toInt32("1f40b",16)

$NEW_PROFILE = @"
{
    "guid": "{$UUID}",
    "name": "CLOUDNATIVE-DOCKER-CLI",
    "icon": "$([System.Char]::ConvertFromUtf32($EmojiIcon))",
    "commandline": "cmd.exe /C docker exec -it $DOCKER_ID bash",
    "suppressApplicationTitle": true
}
"@

            $CONFIG_DATA_JOBJ = ConvertFrom-Json -InputObject "$CONFIG_DATA"

            $CONFIG_DATA_JOBJ.profiles.list += Convertfrom-Json "$NEW_PROFILE"

            ConvertTo-Json -Depth 10 $CONFIG_DATA_JOBJ | Out-File -FilePath "$WT_CONFIG_FILE" -Encoding UTF8

            Write-Output "Created profile[CLOUDNATIVE-DOCKER-CLI] of Windows Terminal configuration[$WT_CONFIG_FILE]"
        }
    }
}