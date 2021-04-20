terraform {
  required_providers {
    azurecaf = {
      source = "aztfmod/azurecaf"
    }
  }
  required_version = ">= 0.13"
}

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags         = merge(local.module_tag, try(var.settings.tags, null), var.base_tags)
  arm_filename = "${path.module}/arm_sql_mi.json"

  # this is the format required by ARM templates
  parameters_body = {
    managedInstanceName = {
      value = azurecaf_name.mssqlmi.result
    }
    location = {
      value = var.location
    }
    skuName = {
      value = var.settings.sku.name
    }
    # skuEdition = {
    #   value = try(var.settings.sku.edition, "GeneralPurpose")
    # }
    administratorLogin = {
      value = var.settings.administratorLogin
    }
    administratorLoginPassword = {
      value = var.settings.administratorLoginPassword
    }
    subnetId = {
      value = var.subnet_id
    }
    storageSizeInGB = {
      value = var.settings.storageSizeInGB
    }
    vCores = {
      value = var.settings.vCores
    }
    licenseType = {
      value = try(var.settings.licenseType, "LicenseIncluded")
    }
    # hardwareFamily = {
    #   value = try(var.settings.hardwareFamily, "Gen5")
    # }
    dnsZonePartner = {
      value = try(var.primary_server_id, "")
    }
    collation = {
      value = try(var.settings.collation, "SQL_Latin1_General_CP1_CI_AS")
    }
    proxyOverride = {
      value = try(var.settings.proxyOverride, "Proxy")
    }
    publicDataEndpointEnabled = {
      value = try(var.settings.publicDataEndpointEnabled, false)
    }
    minimalTlsVersion = {
      value = try(var.settings.minimalTlsVersion, "1.2")
    }
    timezoneId = {
      value = try(var.settings.timezoneId, "UTC")
    }
    storageAccountType = {
      value = try(var.settings.storageAccountType, "GRS")
    }
    managedInstanceTags = {
      value = local.tags
    }
    resourceGroupName = {
      value = var.resource_group_name
    }
  }
}