package caf_tests

import (
	"context"
	"fmt"
	"strings"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/joho/godotenv"

	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMain(m *testing.M) {
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found")
	}
	os.Exit(m.Run())
}

func TestLaunchpadLandingZoneKey(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "launchpad")

	//act
	landingZoneKey := tfState.GetLandingZoneKey()

	//assert
	assert.Equal(t, "launchpad", landingZoneKey)
}

func TestLaunchpadResourceGroupIsExists(t *testing.T) {
	t.Parallel()
	tfState := NewTerraformState(t, "launchpad")
	resourceGroups := tfState.GetResourceGroups()

	for _, resourceGroup := range resourceGroups {
		name := resourceGroup.GetName()
		exists := azure.ResourceGroupExists(t, name, tfState.SubscriptionID)
		assert.True(t, exists, fmt.Sprintf("Resource group (%s) does not exist", name))
	}
}

func TestLaunchpadResourceGroupIsExistsViaClient(t *testing.T) {
	t.Parallel()
	tfState := NewTerraformState(t, "launchpad")
	client, _ := azure.GetResourceGroupClientE(tfState.SubscriptionID)
	resourceGroups := tfState.GetResourceGroups()

	for _, resourceGroup := range resourceGroups {
		rgName := resourceGroup.GetName()
		_, err := client.CheckExistence(context.Background(), rgName)
		assert.NoError(t, err, fmt.Sprintf("Resource group (%s) does not exist", rgName))
	}
}

func TestLaunchpadResourceGroupHasTags(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "launchpad")
	client, _ := azure.GetResourceGroupClientE(tfState.SubscriptionID)
	resourceGroups := tfState.GetResourceGroups()

	for _, resourceGroup := range resourceGroups {
		rgName := resourceGroup.GetName()
		level := resourceGroup.GetLevel()

		rg, errRG := client.Get(context.Background(), rgName)
		assert.NoError(t, errRG, fmt.Sprintf("ResourceGroup (%s) couldn't read", rgName))

		assert.Equal(t, tfState.Environment, *rg.Tags["environment"], "Environment Tag is not correct")
		assert.Equal(t, "launchpad", *rg.Tags["landingzone"], "LandingZone Tag is not correct")
		assert.Equal(t, level, *rg.Tags["level"], "Level Tag is not correct")
	}
}

func TestLaunchpadResourceGroupHasKeyVault(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "launchpad")
	resourceGroups := tfState.GetResourceGroups()

	for _, resourceGroup := range resourceGroups {
		rgName := resourceGroup.GetName()
		if !strings.Contains(rgName, "security") {
			keyVault, err := tfState.GetKeyVaultByResourceGroup(rgName)
			if err != nil {
				panic(err)
			}

			keyVaultName := keyVault.GetName()

			//act
			kv := azure.GetKeyVault(t, rgName, keyVaultName, tfState.SubscriptionID)

			//assert
			assert.NotNil(t, kv, fmt.Sprintf("KeyVault (%s) does not exists", keyVaultName))
		}
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
