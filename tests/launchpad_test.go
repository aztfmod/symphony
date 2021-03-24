package caf_tests

import (
	"context"
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

func TestLaunchpadResourceGroupIsExists(t *testing.T) {
	t.Parallel()

	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)

		exists := azure.ResourceGroupExists(t, resourceGroupName, subscriptionId)

		assert.True(t, exists, fmt.Sprintf("Resource group (%s) does not exist", resourceGroupName))
	}
}

func TestLaunchpadResourceGroupIsExistsViaClient(t *testing.T) {
	t.Parallel()

	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	client, _ := azure.GetResourceGroupClientE(subscriptionId)

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)

		_, err := client.CheckExistence(context.Background(), resourceGroupName)

		assert.NoError(t, err, fmt.Sprintf("Resource group (%s) does not exist", resourceGroupName))
	}
}

func TestLaunchpadResourceGroupHasTags(t *testing.T) {
	t.Parallel()

	environment := os.Getenv("ENVIRONMENT")
	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	client, errClient := azure.GetResourceGroupClientE(subscriptionId)

	assert.NoError(t, errClient, "ResourceGroup Client couldn't read")

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)

		rg, errRG := client.Get(context.Background(), resourceGroupName)

		assert.NoError(t, errRG, fmt.Sprintf("ResourceGroup (%s) couldn't read", resourceGroupName))

		assert.Equal(t, environment, *rg.Tags["environment"], "Environment Tag is not correct")
		assert.Equal(t, "launchpad", *rg.Tags["landingzone"], "LandingZone Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", iLoop), *rg.Tags["level"], "Level Tag is not correct")
	}
}

func TestLaunchpadResourceGroupHasKeyVault(t *testing.T) {
	t.Parallel()

	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)

		keyVaultName := fmt.Sprintf("%s-kv-level%d", prefix, iLoop)

		kv := azure.GetKeyVault(t, resourceGroupName, keyVaultName, subscriptionId)

		assert.NotNil(t, kv, fmt.Sprintf("KeyVault (%s) does not exists", keyVaultName))
	}
}

func TestLaunchpadResourceGroupHasStorageAccount(t *testing.T) {
	t.Parallel()

	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)
		storageAccountName := fmt.Sprintf("%sstlevel%d", prefix, iLoop)

		exists := azure.StorageAccountExists(t, storageAccountName, resourceGroupName, subscriptionId)

		assert.True(t, exists, fmt.Sprintf("Storage Account (%s) does not exists", storageAccountName))
	}
}

func TestLaunchpadKeyVaultHasSubscriptionIdSecret(t *testing.T) {
	t.Parallel()

	prefix := os.Getenv("PREFIX")

	for iLoop := 0; iLoop < 4; iLoop++ {
		keyVaultName := fmt.Sprintf("%s-kv-level%d", prefix, iLoop)

		exists := azure.KeyVaultSecretExists(t, keyVaultName, "subscription-id")

		assert.True(t, exists, "Subscription Id Secret does not exists")
	}
}

func TestLaunchpadKeyVaultHasTenantIdSecret(t *testing.T) {
	t.Parallel()

	prefix := os.Getenv("PREFIX")

	for iLoop := 0; iLoop < 4; iLoop++ {
		keyVaultName := fmt.Sprintf("%s-kv-level%d", prefix, iLoop)

		exists := azure.KeyVaultSecretExists(t, keyVaultName, "tenant-id")

		assert.True(t, exists, "Tenant Id Secret does not exists")
	}
}

func TestLaunchpadKeyVaultHasTags(t *testing.T) {
	t.Parallel()

	environment := os.Getenv("ENVIRONMENT")
	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)

		keyVaultName := fmt.Sprintf("%s-kv-level%d", prefix, iLoop)

		kv := azure.GetKeyVault(t, resourceGroupName, keyVaultName, subscriptionId)

		assert.Equal(t, environment, *kv.Tags["environment"], "Environment Tag is not correct")
		assert.Equal(t, "launchpad", *kv.Tags["landingzone"], "LandingZone Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", iLoop), *kv.Tags["level"], "Level Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", iLoop), *kv.Tags["tfstate"], "TF State is not correct")
	}
}

func TestLaunchpadStorageAccountHasTags(t *testing.T) {
	t.Parallel()

	environment := os.Getenv("ENVIRONMENT")
	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)

		storageAccountName := fmt.Sprintf("%sstlevel%d", prefix, iLoop)

		storage, err := azure.GetStorageAccountE(storageAccountName, resourceGroupName, subscriptionId)

		assert.NoError(t, err, "Storage Account couldn't read")

		assert.Equal(t, environment, *storage.Tags["environment"], "Environment Tag is not correct")
		assert.Equal(t, "launchpad", *storage.Tags["landingzone"], "LandingZone Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", iLoop), *storage.Tags["level"], "Level Tag is not correct")
		assert.Equal(t, fmt.Sprintf("level%d", iLoop), *storage.Tags["tfstate"], "TF State is not correct")
	}
}

func TestLaunchpadStorageAccountHasTFStateContainer(t *testing.T) {
	t.Parallel()

	prefix := os.Getenv("PREFIX")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	for iLoop := 0; iLoop < 4; iLoop++ {
		resourceGroupName := fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop)
		storageAccountName := fmt.Sprintf("%sstlevel%d", prefix, iLoop)
		containerName := "tfstate"

		exists := azure.StorageBlobContainerExists(t, containerName, storageAccountName, resourceGroupName, subscriptionId)

		assert.True(t, exists, "TF State Container does not exists")
	}
}
