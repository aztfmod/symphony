package caf_tests

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"strings"
	"testing"

	terraform "github.com/gruntwork-io/terratest/modules/terraform"
)

type Resource = map[string]interface{}
type AzureResource struct {
	Resource Resource
}

type ResourceGroups = map[string](AzureResource)
type KeyVaults = map[string](AzureResource)
type TerraFormState struct {
	Objects        Resource
	SubscriptionID string
	Environment    string
	Key            string
}

var TfState TerraFormState

func NewTerraformState(t *testing.T, key string) *TerraFormState {
	tfState := new(TerraFormState)
	options := &terraform.Options{
		TerraformDir: os.Getenv("STATE_FILE_PATH"),
	}
	outputJson := terraform.OutputJson(t, options, "objects")
	json.Unmarshal([]byte(outputJson), &tfState.Objects)
	tfState.Key = key
	tfState.SubscriptionID = os.Getenv("ARM_SUBSCRIPTION_ID")
	tfState.Environment = os.Getenv("ENVIRONMENT")
	return tfState
}

func (tfState TerraFormState) GetResources() Resource {
	resourceList := tfState.Objects[tfState.Key].(Resource)
	return resourceList
}

func (tfState TerraFormState) GetClientConfig() Resource {
	resourceList := tfState.GetResources()
	client_config := resourceList["client_config"].(Resource)
	return client_config
}

func (tfState TerraFormState) GetGlobalSettings() Resource {
	resourceList := tfState.GetResources()
	client_config := resourceList["global_settings"].(Resource)
	return client_config
}
func (tfState TerraFormState) GetLandingZoneKey() string {
	client_config := tfState.GetClientConfig()
	landing_zone_key := client_config["landingzone_key"]
	return landing_zone_key.(string)
}

func (tfState TerraFormState) GetResourceGroups() ResourceGroups {
	resourceList := tfState.Objects[tfState.Key].(Resource)
	resourceGroups := resourceList["resource_groups"].(Resource)
	var m ResourceGroups = make(ResourceGroups)
	for key, resourceGroup := range resourceGroups {
		rg := resourceGroup.(Resource)
		m[key] = *NewAzureResource(rg)
	}
	return m
}

func (tfState TerraFormState) GetKeyVaults() KeyVaults {
	resourceList := tfState.Objects[tfState.Key].(Resource)
	keyVaults := resourceList["keyvaults"].(Resource)

	var m KeyVaults
	m = make(KeyVaults)
	for key, resourceGroup := range keyVaults {
		kv := resourceGroup.(Resource)
		m[key] = *NewAzureResource(kv)
	}
	return m
}

func (tfState TerraFormState) GetKeyVaultByResourceGroup(resourceGroup string) (AzureResource, error) {
	keyVaults := tfState.GetKeyVaults()
	for _, keyVault := range keyVaults {
		id := keyVault.Resource["id"].(string)
		searchString := fmt.Sprintf("resourceGroups/%s", resourceGroup)
		if strings.Contains(id, searchString) {
			return keyVault, nil
		}
	}
	return *NewAzureResource(nil), errors.New("Keyvault not found")
}

func NewAzureResource(resource Resource) *AzureResource {
	azureResource := new(AzureResource)
	azureResource.Resource = resource
	return azureResource
}

func (r AzureResource) GetString(key string) string {
	return r.Resource[key].(string)
}

func (r AzureResource) GetName() string {
	return r.GetString("name")
}

func (r AzureResource) GetResource(key string) Resource {
	return r.Resource[key].(Resource)
}
func (r AzureResource) GetTags() Resource {
	return r.GetResource("tags")
}
func (r AzureResource) GetLevel() string {
	tags := r.GetTags()
	return tags["level"].(string)
}
