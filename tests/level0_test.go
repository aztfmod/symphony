package caf_tests

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	terraform "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestLaunchpadLandingZoneKey(t *testing.T) {
	//arrange
	t.Parallel()
	test := prepareTestTable()
	outputJson := terraform.OutputJson(t, test.TerraformOptions, "objects")

	//act
	landingZoneKey := getLandingZoneKey(outputJson)

	//assert
	assert.Equal(t, "launchpad", landingZoneKey)
}

func TestLaunchpadResourceGroupIsExists(t *testing.T) {
	//arrange
	t.Parallel()
	test := prepareTestTable()
	outputJson := terraform.OutputJson(t, test.TerraformOptions, "objects")
	resourceGroups := getResourceGroups(outputJson, "launchpad")

	for _, resourceGroup := range resourceGroups {
		rgName := resourceGroup["name"].(string)

		//act
		exists := azure.ResourceGroupExists(t, rgName, test.SubscriptionID)

		//assert
		assert.True(t, exists, fmt.Sprintf("Resource group (%s) does not exist", rgName))
	}
}

func TestLaunchpadResourceGroupIsExistsViaClient(t *testing.T) {
	//arrange
	t.Parallel()
	test := prepareTestTable()
	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)
	outputJson := terraform.OutputJson(t, test.TerraformOptions, "objects")
	resourceGroups := getResourceGroups(outputJson, "launchpad")

	for _, resourceGroup := range resourceGroups {
		rgName := resourceGroup["name"].(string)

		//act
		_, err := client.CheckExistence(context.Background(), rgName)

		//assert
		assert.NoError(t, err, fmt.Sprintf("Resource group (%s) does not exist", rgName))
	}

}

func TestLaunchpadResourceGroupHasTags(t *testing.T) {
	//arrange
	t.Parallel()
	test := prepareTestTable()
	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)
	outputJson := terraform.OutputJson(t, test.TerraformOptions, "objects")
	resourceGroups := getResourceGroups(outputJson, "launchpad")

	for _, resourceGroup := range resourceGroups {
		rgName := resourceGroup["name"].(string)
		tags := resourceGroup["tags"].(map[string]interface{})
		level := tags["level"].(string)

		rg, errRG := client.Get(context.Background(), rgName)
		assert.NoError(t, errRG, fmt.Sprintf("ResourceGroup (%s) couldn't read", rgName))

		assert.Equal(t, test.Environment, *rg.Tags["environment"], "Environment Tag is not correct")
		assert.Equal(t, "launchpad", *rg.Tags["landingzone"], "LandingZone Tag is not correct")
		assert.Equal(t, level, *rg.Tags["level"], "Level Tag is not correct")
	}
}

func TestLaunchpadResourceGroupHasKeyVault(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for _, landingZone := range test.LandingZones {
		kv := azure.GetKeyVault(t, landingZone.ResourceGroupName, landingZone.KeyVaultName, test.SubscriptionID)

		assert.NotNil(t, kv, fmt.Sprintf("KeyVault (%s) does not exists", landingZone.KeyVaultName))
	}
}

func TestLaunchpadResourceGroupHasStorageAccount(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for _, landingZone := range test.LandingZones {
		exists := azure.StorageAccountExists(t, landingZone.StorageAccountName, landingZone.ResourceGroupName, test.SubscriptionID)

		assert.True(t, exists, fmt.Sprintf("Storage Account (%s) does not exists", landingZone.StorageAccountName))
	}
}

func TestLaunchpadKeyVaultHasTags(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for _, landingZone := range test.LandingZones {
		kv := azure.GetKeyVault(t, landingZone.ResourceGroupName, landingZone.KeyVaultName, test.SubscriptionID)

		assert.Equal(t, test.Environment, *kv.Tags["environment"], "Environment Tag is not correct")
		assert.Equal(t, "launchpad", *kv.Tags["landingzone"], "LandingZone Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", landingZone.Level), *kv.Tags["level"], "Level Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", landingZone.Level), *kv.Tags["tfstate"], "TF State Tag is not correct")
	}
}

func TestLaunchpadStorageAccountHasTags(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for _, landingZone := range test.LandingZones {
		storage, err := azure.GetStorageAccountE(landingZone.StorageAccountName, landingZone.ResourceGroupName, test.SubscriptionID)

		assert.NoError(t, err, "Storage Account couldn't read")

		assert.Equal(t, test.Environment, *storage.Tags["environment"], "Environment Tag is not correct")
		assert.Equal(t, "launchpad", *storage.Tags["landingzone"], "LandingZone Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", landingZone.Level), *storage.Tags["level"], "Level Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", landingZone.Level), *storage.Tags["tfstate"], "TF State Tag is not correct")
	}
}

func TestLaunchpadStorageAccountHasTFStateContainer(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for _, landingZone := range test.LandingZones {
		containerName := "tfstate"

		exists := azure.StorageBlobContainerExists(t, containerName, landingZone.StorageAccountName, landingZone.ResourceGroupName, test.SubscriptionID)

		assert.True(t, exists, "TF State Container does not exist")
	}
}
