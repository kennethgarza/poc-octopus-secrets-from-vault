

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
      value = [
        {
          value = "Default.Value.1"
        },
        {
          value = "Default.Value.2.BOKOnly"
          scope = {
            environments = [
              "PREPROD",
              "UAT",
              "PROD"
            ]
            tenant_tags = [
              "Tenant/Bank of Kenneth"
            ]
          }
        },
        {
          value = "Default.Value.2.Preprod_ONLY"
          scope = {
            environments = [
              "PREPROD"
            ]
          }
        },
        {
          value = "Default.Value.2.FI_HOSTED_ONLY"
          scope = {
            tenant_tags = [
              "Tenant/FI-Hosted"
            ]
          }
        }
      ]
  })
}

resource "vault_kv_secret_v2" "secret_2" {
  mount = vault_mount.octopus_default_secrets.path
  name = "Secrets.Another.Variable"
  data_json = jsonencode({
    value = [
      {
        value = "this is just a plain secret"
      }
    ]
  })
}

