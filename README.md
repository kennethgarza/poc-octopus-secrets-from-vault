# [POC] - Octopus Deploy Secret Variables Sourced from Hashicorp VAULT
OctopusDeploy Variable Secrets sourced from Hashicorp Vault example

## Overview
Prove that OctopusDeploy Secret Variables can be sourced from Vault securely using Terraform.

## Devcontainer Description

### Sql Server
Needed for Octopus Deploy

### OctopusDeploy Container
Octopus Deploy Server. Can be accessed via http://localhost:8080

### Vault Container
Can be access via http://localhost:8200

### Dev Environment (Terraform)
Main Dev Environment.  Contains code needed for terraform.  Docker container runs the `initial setup` terraform code in the `.devcontainer` folder.  This is used to setup octopus and vault with some test configuration data.

Terraform code in the root folder can be used to populate the secrets from vault into octopus deploy.


