terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
  required_version = ">= 0.13"
}

locals {
  databases = [
    for key, value in var.settings.databases : var.databases[try(value.lz_key, var.client_config.landingzone_key)][value.database_key].id
  ]
}