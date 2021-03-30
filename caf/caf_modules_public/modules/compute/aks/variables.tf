
variable global_settings {
  description = "Global settings object (see module README.md)"
}
variable client_config {}
variable diagnostics {}
variable settings {}
variable subnets {}
variable resource_group {}
variable admin_group_object_ids {}
variable base_tags {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map
}
variable diagnostic_profiles {
  default = null
}