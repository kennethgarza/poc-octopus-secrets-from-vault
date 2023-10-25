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

## Secrets Format from Vault to Octopus Deploy
To Support octopus scoping mechanism in from vault, we have standardized how the keys/values should be structured.

### Key Scoped

#### default
The Default value, does not have any scoping

#### <env_list>:<tenant_tag_list>
Filters on environment names in a comma list, tenant tag list.


For Example 
```
PREPROD,UAT:FI-Hosted,FI-Template
    scopes to (Tenant-Tags = FI-Hosted OR FI-Template) AND (Environments = PREPROD OR UAT)
:FI-Hosted
    scopes to (Tenant-Tags = FI-Hosted only), no scoping to Environments
PREPROD:
    scopes to (Environments = PREPROD only), no scoping to Tenant-Tags
default
    no scoping at all, this is a special keyword, does not need the colon
```

### Caveats
The Environment names and tenant tags MUST exist in octopus already beforehand.  The terraform scripts in this demo are not designed to be super resiliant, and will fail if you use an environment name, or tenant tag that does not exist.  Not including the color (:) for non-default scoped items will result in an error in the terraform script.

The environment name is Case Sensitive.  Preprod != PREPROD

The tenant tag is NOT case sensitive, however, using an improper case will result octopus and the state file being out of sync.  Octopus will save the data in the proper case while terrafor will save it in the format that is in vault.

When it comes time to update next time, Terraform will see the `fi-template` != `FI-Template` and will result in an `update-in-place` plan step.  If applied, this change will not actually change anything and will result in the next Plan/Apply to have the same issues.  To prevent this, it is best that Vault Key names contain the correct Tenant Tag Name Casing.


