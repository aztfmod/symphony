terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
  required_version = ">= 0.13"
}


locals {
  os_type = lower(var.settings.os_type)
  # Generate SSH Keys only if a public one is not provided
  create_sshkeys = local.os_type == "linux" && try(var.settings.public_key_pem_file == "", true)
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags = merge(var.base_tags, local.module_tag, try(var.settings.tags, null))
}