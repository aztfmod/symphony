variable "cloud" {
  description = "Cloud configuration objects"
  default     = {}
}

# variable "acrLoginServerEndpoint" {
#   default = {}
# }
# variable "attestationEndpoint" {
#   default = {}
# }
# variable "azureDatalakeAnalyticsCatalogAndJobEndpoint" {
#   default = {}
# }
# variable "azureDatalakeStoreFileSystemEndpoint" {
#   default = {}
# }
# variable "keyvaultDns" {
#   default = {}
# }
# variable "mariadbServerEndpoint" {
#   default = {}
# }
# variable "mhsmDns" {
#   default = {}
# }
# variable "mysqlServerEndpoint" {
#   default = {}
# }
# variable "postgresqlServerEndpoint" {
#   default = {}
# }
# variable "sqlServerHostname" {
#   default = {}
# }
# variable "storageEndpoint" {
#   default = {}
# }
# variable "storageSyncEndpoint" {
#   default = {}
# }
# variable "synapseAnalyticsEndpoint" {
#   default = {}
# }
# variable "activeDirectory" {
#   default = {}
# }
# variable "activeDirectoryDataLakeResourceId" {
#   default = {}
# }
# variable "activeDirectoryGraphResourceId" {
#   default = {}
# }
# variable "activeDirectoryResourceId" {
#   default = {}
# }
# variable "appInsightsResourceId" {
#   default = {}
# }
# variable "appInsightsTelemetryChannelResourceId" {
#   default = {}
# }
# variable "attestationResourceId" {
#   default = {}
# }
# variable "azmirrorStorageAccountResourceId" {
#   default = {}
# }
# variable "batchResourceId" {
#   default = {}
# }
# variable "gallery" {
#   default = {}
# }
# variable "logAnalyticsResourceId" {
#   default = {}
# }
# variable "management" {
#   default = {}
# }
# variable "mediaResourceId" {
#   default = {}
# }
# variable "microsoftGraphResourceId" {
#   default = {}
# }
# variable "ossrdbmsResourceId" {
#   default = {}
# }
# variable "portal" {
#   default = {}
# }
# variable "resourceManager" {
#   default = {}
# }
# variable "sqlManagement" {
#   default = {}
# }
# variable "synapseAnalyticsResourceId" {
#   default = {}
# }
# variable "vmImageAliasDoc" {
#   default = {}
# }

variable "acrLoginServerEndpoint" {
  default = ".azurecr.io"
}
variable "attestationEndpoint" {
  default = ".attest.azure.net"
}
variable "azureDatalakeAnalyticsCatalogAndJobEndpoint" {
  default = "azuredatalakeanalytics.net"
}
variable "azureDatalakeStoreFileSystemEndpoint" {
  default = "azuredatalakestore.net"
}
variable "keyvaultDns" {
  default = ".vault.azure.net"
}
variable "mariadbServerEndpoint" {
  default = ".mariadb.database.azure.com"
}
variable "mhsmDns" {
  default = ".managedhsm.azure.net"
}
variable "mysqlServerEndpoint" {
  default = ".mysql.database.azure.com"
}
variable "postgresqlServerEndpoint" {
  default = ".postgres.database.azure.com"
}
variable "sqlServerHostname" {
  default = ".from_caf_solution.windows.net"
}
variable "storageEndpoint" {
  default = "core.windows.net"
}
variable "storageSyncEndpoint" {
  default = "afs.azure.net"
}
variable "synapseAnalyticsEndpoint" {
  default = ".dev.azuresynapse.net"
}
variable "activeDirectory" {
  default = "https://login.microsoftonline.com"
}
variable "activeDirectoryDataLakeResourceId" {
  default = "https://datalake.azure.net/"
}
variable "activeDirectoryGraphResourceId" {
  default = "https://graph.windows.net/"
}
variable "activeDirectoryResourceId" {
  default = "https://management.core.windows.net/"
}
variable "appInsightsResourceId" {
  default = "https://api.applicationinsights.io"
}
variable "appInsightsTelemetryChannelResourceId" {
  default = "https://dc.applicationinsights.azure.com/v2/track"
}
variable "attestationResourceId" {
  default = "https://attest.azure.net"
}
variable "azmirrorStorageAccountResourceId" {
  default = "null"
}
variable "batchResourceId" {
  default = "https://batch.core.windows.net/"
}
variable "gallery" {
  default = "https://gallery.azure.com/"
}
variable "logAnalyticsResourceId" {
  default = "https://api.loganalytics.io"
}
variable "management" {
  default = "https://management.core.windows.net/"
}
variable "mediaResourceId" {
  default = "https://rest.media.azure.net"
}
variable "microsoftGraphResourceId" {
  default = "https://graph.microsoft.com/"
}
variable "ossrdbmsResourceId" {
  default = "https://ossrdbms-aad.database.windows.net"
}
variable "portal" {
  default = "https://portal.azure.com"
}
variable "resourceManager" {
  default = "https://management.azure.com/"
}
variable "sqlManagement" {
  default = "https://management.core.windows.net:8443/"
}
variable "synapseAnalyticsResourceId" {
  default = "https://dev.azuresynapse.net"
}
variable "vmImageAliasDoc" {
  default = "https://raw.githubusercontent.com/Azure/azure-rest-api-specs/master/arm-compute/quickstart-templates/aliases.json"
}
