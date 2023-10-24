terraform {
  required_providers {
    octopusdeploy = {
      source = "OctopusDeployLabs/octopusdeploy"
    }
    vault = {
      source = "hashicorp/vault"
    }
  }

  backend "local" {} ## we are only testing here
}

provider "octopusdeploy" {
  address = "http://octopus:8080"
  api_key = "API-L2GV2ELTCZDRANT1OQO045GPZHXFGWR"
}

provider vault {
  address = "http://vault:8200"
  token   = "00000000-0000-0000-0000-000000000000"
}