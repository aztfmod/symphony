keyvault_access_policies = {
  level1 = {
    msi_level1 = {
      managed_identity_key = "level1"
      secret_permissions   = ["Get"]
    }
  }

  level2 = {
    msi_level2 = {
      managed_identity_key = "level2"
      secret_permissions   = ["Get"]
    }
  }

  level3 = {
    msi_level3 = {
      managed_identity_key = "level3"
      secret_permissions   = ["Get"]
    }
  }

  level4 = {
    msi_level4 = {
      managed_identity_key = "level4"
      secret_permissions   = ["Get"]
    }
  }
}
