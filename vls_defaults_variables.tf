## create the library in octopus
resource "octopusdeploy_library_variable_set" "default_secrets" {
    name = "Default - Test"
}

## non secret variables can be just put in here for maintenance
resource "octopusdeploy_variable" "default_nonsecret_1" {
    owner_id = octopusdeploy_library_variable_set.default_secrets.id
    type = "String"
    name = "Default.NonSecret.1"
    value = "This is a plain value"
}