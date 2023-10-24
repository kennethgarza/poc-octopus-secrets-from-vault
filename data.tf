### manage user passwords
data "octopusdeploy_environments" "environments" {
    take = 1000
}

data "octopusdeploy_tag_sets" "tag_sets" {
    take = 1000
}

locals {
    envs = {
        for v in data.octopusdeploy_environments.environments.environments : lower(v.name) => v.id
    }
}