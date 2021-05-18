landingzone = {
  backend_type        = "azurerm"
  level               = "level3"
  key                 = "sql_server"
  global_settings_key = "shared_services"
  tfstates = {
    shared_services = {
      level   = "lower"
      tfstate = "caf_shared_services.tfstate"
    }
    networking_hub = {
      level   = "lower"
      tfstate = "networking_hub.tfstate"
    }
  }
}

resource_groups = {
  sql_region1 = {
    name   = "sql-rg1"
    region = "region1"
  }
}

mssql_servers = {
  sql_rg1 = {
    name                = "sql-rg1"
    region              = "region1"
    resource_group_key  = "sql_region1"
    administrator_login = "sqladmin"

    # Generate a random password and store it in keyvault secret
    keyvault_key                  = "sql-rg1"
    connection_policy             = "Default"
    system_msi                    = true
    public_network_access_enabled = false

    # Required if no public access
    private_endpoints = {
      # Require enforce_private_link_endpoint_network_policies set to true on the subnet
      private-link-level4 = {
        name               = "test-sql-rg1"
        lz_key             = "networking_hub"
        vnet_key           = "hub_re1"
        subnet_key         = "private_endpoints"
        resource_group_key = "sql_region1"

        private_service_connection = {
          name                 = "test-sql-rg1"
          is_manual_connection = false
          subresource_names    = ["sqlServer"]
        }

        private_dns = {
          zone_group_name = "privatelink_database_windows_net"
          # lz_key          = ""   # If the DNS keys are deployed in a remote landingzone
          keys = ["privatelink"]
        }
      }
    }
  }
}

keyvaults = {
  sql_rg1 = {
    name               = "sqlrg1"
    resource_group_key = "sql_region1"
    sku_name           = "standard"

    creation_policies = {
      logged_in_user = {
        secret_permissions = ["Set", "Get", "List", "Delete", "Purge"]
      }
    }
  }
}

# SQL Endpoint: https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns
# Private DNS: https://docs.microsoft.com/en-us/azure/dns/private-dns-getstarted-portal

# OWH - this privatelink is ref'ed in the SQL Endpoint doc, but just want to confirm it can
# be changed as in the Private DNS getting started doc.

private_dns = {
  privatelink = {
    name               = "privatelink.database.windows.net"
    resource_group_key = "sql_region1"

    vnet_links = {
      sqltest = {
        name     = "sqltest"
        lz_key   = "networking_hub"
        vnet_key = "hub_re1"
      }

    }
  }
}
