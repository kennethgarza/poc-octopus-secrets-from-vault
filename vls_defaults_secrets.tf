variable "vault_mount" {
    default = "octopus/default/secrets"
    description = "the vault mount path"
    type = string
}

## get all the secrets
data "vault_kv_secrets_list_v2" "secrets" {
    mount = var.vault_mount
}

locals {
    secret_keys = [
        for v in nonsensitive(data.vault_kv_secrets_list_v2.secrets.names) : v
    ]
}

## get the secrets values for each key
data "vault_kv_secret_v2" "secrets" {
    for_each = {
        for v in local.secret_keys: v => v 
    }

    mount = var.vault_mount
    name = each.value
}

locals {
    secrets_values_decoded = {
        for k,v in data.vault_kv_secret_v2.secrets: k => jsondecode(v.data_json)
    }

    secrets_with_scope_pass_1 = flatten([
        for k, v in local.secrets_values_decoded : [
            for kk,vv in v : {
                key = k
                value = vv
                envs = lower(kk) == "default" ? "none" : split(":", kk)[0]
                tenant_tags = lower(kk) == "default" ? "none" : split(":", kk)[1]
            }
        ]
    ])
    
    secrets_with_scope_pass_2 = flatten([
        for v in local.secrets_with_scope_pass_1 : {
            key = v.key 
            value = v.value,
            envs = coalesce(v.envs, "none") == "none" ? null : split(",", v.envs)
            tenant_tags = coalesce(v.tenant_tags, "none") == "none" ? null : split(",", v.tenant_tags)
        }
    ])
    
    secrets_with_scope_pass_3 = flatten([
        for v in local.secrets_with_scope_pass_2 : {
            key = v.key 
            value = v.value 
            index = replace(lower(join(":", [
                "arn",
                "octo",
                "secrets",
                v.key,
                join("|", v.envs == null ? [] : v.envs),
                replace(join("|", v.tenant_tags == null ? [] : v.tenant_tags), "///", "_")
            ])), "/ /", "-")
            envs = v.envs == null ? null : [
                for e in v.envs : local.envs[e]
            ]
            tenant_tags =  v.tenant_tags
            scope_index = (length(coalesce(v.envs, [])) + length(coalesce(v.tenant_tags, [])) > 0) ? [ 1 ] : [ ]
        }
    ])
    
    secrets_map = {
        for v in local.secrets_with_scope_pass_3: v.index => v
    }
}

## octopus secrets
resource "octopusdeploy_library_variable_set" "secrets" {
    name = "Secrets"
    description = "Imported secrets from Vault - Do not modify, these will be overwritten during the next sync"
}

resource "octopusdeploy_variable" "secrets" {
    for_each = nonsensitive(local.secrets_map)

    description = each.key

    owner_id = octopusdeploy_library_variable_set.secrets.id
    type = "Sensitive"

    is_sensitive = true 

    name = each.value.key

    sensitive_value = each.value.value

    dynamic "scope" {
        for_each = each.value.scope_index

        content {
            environments = each.value.envs
            tenant_tags = each.value.tenant_tags
        }
    }
}
