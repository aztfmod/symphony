# Debugging CAF Applications

This document will outlines steps that you can use to debug a CAF deployment.

---

## Terraform Debugging

Terraform provides [extra debugging output](https://www.terraform.io/docs/internals/debugging.html) and the ability to log to a log file.

In order to get verbose output from terraform export the following environment variables

* export TF_LOG=TRACE
* export TF_LOG_PATH=tf_log.txt

---

### Locals

CAF makes heavy use of [Terraform Local Values](https://www.terraform.io/docs/language/values/locals.html). It is the primary mechanism by which to take data from remote state and make it accessible to the current landing zone or add-on. In addition, CAF also uses the [merge function](https://www.terraform.io/docs/language/functions/merge.html) to combine elements from the current lz's config and remote state.

### terraform_remote_state

The file locals.remote_tfstates.tf contains the following terraform stanza

```hcl
data "terraform_remote_state" "remote" {
  for_each = try(var.landingzone.tfstates, {})

  backend = var.landingzone.backend_type
  config = {
    storage_account_name = local.landingzone[try(each.value.level, "current")].storage_account_name
    container_name       = try(each.value.workspace, local.landingzone[try(each.value.level, "current")].container_name)
    resource_group_name  = local.landingzone[try(each.value.level, "current")].resource_group_name
    subscription_id      = var.tfstate_subscription_id
    key                  = each.value.tfstate
  }
}
```

---

## Outputs

[Terraform Output Values](https://www.terraform.io/docs/language/values/outputs.html) is a great way to see what is being consumed by the locals file and for seeing what local values are set.

There are main predefined outputs that are provided by landing zones or add-ons

### - `objects`

This contains global settings and output values from the various CAF modules used in this lz or add-ons configuration.

Example:

```hcl
 "objects" = tomap({
    "cluster_aks" = {
      "aks_clusters" = {
        "cluster_re1" = {
          "aks_kubeconfig_admin_cmd" = "az aks get-credentials --name wllr-aks-akscluster-re1-001 --resource-group wllr-rg-aks-re1 --overwrite-existing --admin"
          "aks_kubeconfig_cmd" = "az aks get-credentials --name wllr-aks-akscluster-re1-001 --resource-group wllr-rg-aks-re1 --overwrite-existing"
          "cluster_name" = "wllr-aks-akscluster-re1-001"
          "enable_rbac" = true
          "id" = "/subscriptions/<sub_id>/resourcegroups/wllr-rg-aks-re1/providers/Microsoft.ContainerService/managedClusters/wllr-aks-akscluster-re1-001"
          "identity" = tolist([
            {
              "principal_id" = "<principal_id>"
              "tenant_id" = "<tenant_id>"
              "type" = "SystemAssigned"
              "user_assigned_identity_id" = ""
            },
          ])
 ... # The rest is omitted for brevity
```

The above objects come from a level3 state file, specifically one that deployed an aks cluster. The outputs above match the outputs of the [CAF AKS module](https://github.com/aztfmod/terraform-azurerm-caf/blob/master/modules/compute/aks/output.tf#L13).

In addition to module outputs, the objects output value contains global settings.

### - `tfstates`

This contains a map with keys for the various platform levels, as well as custom keys for solution levels. This is the reference to the remote state storage account for that level.

Example:

```hcl
"tfstates" = tomap({
    "foundations" = {
      "container_name" = "tfstate"
      "key" = "caf_foundations.tfstate"
      "level" = "level1"
      "resource_group_name" = "wllr-rg-launchpad-level1"
      "storage_account_name" = "wllrstlevel1"
      "subscription_id" = "<subscription_id>"
      "tenant_id" = "<tenant_id>"
    }
})
```

In the hcl above, it's useful to print out the value of `var.landingzone.tfstates` to ensure that it is being read correctly. An output value can be created like so:

```hcl
output "landingzone_tfstates" {
   value     = var.landingzone.tfstates
}
```

To see the value , run the rover command to apply your lz or add-on.

---

## Debugging Tips

CAF makes extensive use of the [Terraform try function](https://www.terraform.io/docs/language/functions/try.html) in order to set default value. This coupled with [For Expressions](https://www.terraform.io/docs/language/expressions/for.html) can lead to a situation where a particular path may not execute (such as an add-on.)

In this case there are a few debugging steps:

* Simple Resource Group.  Find an isolated TF file and enter a simple resource group stanza to verify that this file is being executed. An example would be

```hcl
resource "azurerm_resource_group" "example" {
  name     = "caf_debug_test"
  location = "West US"
}
```

After running rover apply, you should see a new resource group named caf_debug_test. If one does not exist, then we can surmise that the execution path did not include this file.

We can also use resource groups to validate the content of an object. For example, if we wanted to debug the following stanza:

```hcl
module "app1" {
  source   = "./app"
  for_each = try(local.clusters[var.cluster_re1_key], null) != null ? { (var.cluster_re1_key) = local.clusters[var.cluster_re1_key] } : {}

  cluster     = each.value
  namespaces  = var.namespaces
  helm_charts = var.helm_charts

  providers = {
    kubernetes.k8s = kubernetes.k8s1
    helm.helm      = helm.helm1
  }
}
```

We could use the output approach above to write out the values for `cluster_re1_key` and `local.clusters`

We can also use a for_each in a resource group to see if the for each in the app1 module is being run.

```hcl 
resource "azurerm_resource_group" "example" {
  for_each = try(local.clusters[var.cluster_re1_key], null) != null ? { (var.cluster_re1_key) = local.clusters[var.cluster_re1_key] } : {}
  name     = "caf_debug_${each.value.cluster_name}"
  location = "West US"
}
```

