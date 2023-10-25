

resource "vault_mount" "octopus_default_secrets" {
  path        = "octopus/default/secrets"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "octopus_default_secrets" {
  mount                = vault_mount.octopus_default_secrets.path
  max_versions         = 5
  cas_required         = false
}

## a secret in octopus/default/secrets
resource "vault_kv_secret_v2" "secret_1" {
  mount = vault_mount.octopus_default_secrets.path
  name = "Secrets.Name.1"

  data_json = jsonencode({
    "default" : "default value",
    ":Tenant/BOK": "no environment scope, bank of kenneth tenant tag",
    "PREPROD,UAT:Tenant/FI-Hosted" : "scoped to preprod, uat with tenant tag fi-hosted",
    "PREPROD:" : "scoped to preprod, no tenant tag scope"
  })
}

resource "vault_kv_secret_v2" "secret_2" {
  mount = vault_mount.octopus_default_secrets.path
  name = "Secrets.Another.Variable"

  data_json = jsonencode({
    "default" = "this is just a plain secret"
  })
}

