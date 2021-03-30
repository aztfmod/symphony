locals {

  gateway_vnet_local = try(var.vnets[var.client_config.landingzone_key][var.settings.vnet_key], null)
  private_vnet_local = try(var.vnets[var.client_config.landingzone_key][var.settings.front_end_ip_configurations.private.vnet_key], null)
  public_vnet_local  = try(var.vnets[var.client_config.landingzone_key][var.settings.front_end_ip_configurations.public.vnet_key], null)

  gateway_vnet_remote = try(var.vnets[var.settings.lz_key][var.settings.vnet_key], null)
  private_vnet_remote = try(var.vnets[var.settings.front_end_ip_configurations.private.lz_key][var.settings.front_end_ip_configurations.private.vnet_key], null)
  public_vnet_remote  = try(var.vnets[var.settings.front_end_ip_configurations.public.lz_key][var.settings.front_end_ip_configurations.public.vnet_key], null)

  gateway_vnet = merge(local.gateway_vnet_local, local.gateway_vnet_remote)
  private_vnet = merge(local.private_vnet_local, local.private_vnet_remote)
  public_vnet  = merge(local.public_vnet_local, local.public_vnet_remote)

  ip_configuration = {
    gateway = {
      subnet_id = local.gateway_vnet.subnets[var.settings.subnet_key].id
    }
    private = {
      subnet_id = local.private_vnet.subnets[var.settings.front_end_ip_configurations.private.subnet_key].id
      cidr      = local.private_vnet.subnets[var.settings.front_end_ip_configurations.private.subnet_key].cidr
    }
    public = {
      subnet_id     = try(local.public_vnet.subnets[var.settings.front_end_ip_configurations.public.subnet_key].id, null)
      ip_address_id = try(var.public_ip_addresses[var.client_config.landingzone_key][var.settings.front_end_ip_configurations.public.public_ip_key].id, var.public_ip_addresses[var.settings.front_end_ip_configurations.public.lz_key][var.settings.front_end_ip_configurations.public.public_ip_key].id)
    }
  }

  private_cidr       = local.ip_configuration.private.cidr[var.settings.front_end_ip_configurations.private.subnet_cidr_index]
  private_ip_address = cidrhost(local.private_cidr, var.settings.front_end_ip_configurations.private.private_ip_offset)

}
