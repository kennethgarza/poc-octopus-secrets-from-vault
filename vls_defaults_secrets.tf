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
        for k,v in data.vault_kv_secret_v2.secrets: k => jsondecode(v.data_json)["value"]
    }

    secrets_values_array = flatten([
        for k,v in local.secrets_values_decoded : [
            for vv in v : {
                key = k,
                value = vv.value
                environments = lookup(lookup(vv, "scope", {}), "environments", [])
                tenant_tags = lookup(lookup(vv, "scope", {}), "tenant_tags", [])
            }
        ]
    ])

    secrets_values_array_pass2 = [
        for v in local.secrets_values_array : {
            key = v.key,
            index = lower(join(":", [
                "arn",
                "octopus_secrets",
                v.key,
                join("_", v.environments),
                replace(join("_", v.tenant_tags), "/Tenant//", "")
            ]))
            value = v.value
            environments = length(v.environments) > 0 ? [
                for env in v.environments : local.envs[(lower(env))]
            ] : null
            tenant_tags = length(v.tenant_tags) > 0 ? v.tenant_tags : null
            scope_index = (length(v.environments) + length(v.tenant_tags) > 0) ? [ 1 ] : [ ]
        }
    ]

    secrets_values = {
        for v in local.secrets_values_array_pass2 : v.index => v
    }
}

## octopus secrets
resource "octopusdeploy_library_variable_set" "secrets" {
    name = "secrets"
    description = "Imported secrets from Vault - Do not modify, these will be overwritten during the next sync"
}

resource "octopusdeploy_variable" "secrets" {
    for_each = nonsensitive(local.secrets_values)

    description = each.value.index

    owner_id = octopusdeploy_library_variable_set.secrets.id
    type = "Sensitive"

    is_sensitive = true 

    name = each.value.key
    sensitive_value = each.value.value
    dynamic "scope" {
        for_each = each.value.scope_index

        content {
            environments = each.value.environments
            tenant_tags = each.value.tenant_tags
        }
    }
}
