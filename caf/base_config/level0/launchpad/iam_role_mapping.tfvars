
#
# Services supported: subscriptions, storage accounts and resource groups
# Can assign roles to: AD groups, AD object ID, AD applications, Managed identities
#
role_mapping = {
  built_in_role_mapping = {
    subscriptions = {
      # Required both to create Azure resources on their respective levels
      # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity
      logged_in_subscription = {
        "Contributor" = {
          managed_identities = {
            keys = ["level1", "level2", "level3", "level4"]
          }
        }
        "User Access Administrator" = {
          managed_identities = {
            keys = ["level1", "level2", "level3", "level4"]
          }
        }
      }
    }
    /*
    # Owner access inherited through subscription
    storage_accounts = {
      level0 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
        }
      }
      level1 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
        }
      }
      level2 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
        }
      }
      level3 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
        }
      }
      level4 = {
        "Storage Blob Data Contributor" = {
          logged_in = {
            keys = ["user"]
          }
        }
      }
    } */
  }
}
