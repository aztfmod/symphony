variable name {}
variable resource_group_name {
  description = "(Required) The name of the resource group where to create the resource."
  type        = string
}
variable location {
  description = "(Required) Specifies the supported Azure location where to create the resource. Changing this forces a new resource to be created."
  type        = string
}
variable disable_bgp_route_propagation {}
variable tags {
  description = "(Required) Map of tags to be applied to the resource"
  type        = map
}
variable base_tags {
  description = "Base tags for the resource to be inherited from the resource group."
  type        = map
}