module diagnostics {
  source = "../diagnostics"
  count  = try(var.subscription.diagnostic_profiles, null) == null ? 0 : 1

  resource_id       = var.subscription_key == "logged_in_subscription" ? format("/subscriptions/%s", var.primary_subscription_id) : format("/subscriptions/%s", var.subscription.subscription_id)
  resource_location = var.global_settings.regions[var.global_settings.default_region]
  diagnostics       = var.diagnostics
  profiles          = try(var.subscription.diagnostic_profiles, null)
  global_settings   = var.global_settings
}