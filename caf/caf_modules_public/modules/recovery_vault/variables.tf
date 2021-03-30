variable location {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable settings {}
variable global_settings {
  description = "Global settings object (see module README.md)"
}
variable resource_group_name {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable diagnostics {}
variable base_tags {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map
}
variable private_endpoints {}
variable vnets {}
variable client_config {
  description = "Client configuration object (see module README.md)."
}
variable resource_groups {}
variable identity {
  default = null
}
variable private_dns {
  default = {}
}