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

	resourceGroupName := os.Getenv("RESOURCE_GROUP_NAME")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	exists := azure.ResourceGroupExists(t, resourceGroupName, subscriptionId)

	assert.True(t, exists, "Resource group does not exist")
}

func TestLaunchpadResourceGroupIsExistsViaClient(t *testing.T) {
	t.Parallel()

	resourceGroupName := os.Getenv("RESOURCE_GROUP_NAME")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	client, _ := azure.GetResourceGroupClientE(subscriptionId)

	_, err := client.CheckExistence(context.Background(), resourceGroupName)

	assert.NoError(t, err, "Resource group does not exist")
}

func TestLaunchpadResourceGroupHasTags(t *testing.T) {
	t.Parallel()

	environment := os.Getenv("ENVIRONMENT")
	resourceGroupName := os.Getenv("RESOURCE_GROUP_NAME")
	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")

	client, errClient := azure.GetResourceGroupClientE(subscriptionId)

	assert.NoError(t, errClient, "ResourceGroup Client couldn't read")

	rg, errRG := client.Get(context.Background(), resourceGroupName)

	assert.NoError(t, errRG, "ResourceGroup couldn't read")

	assert.Equal(t, environment, *rg.Tags["environment"], "Environment Tag is not correct")
	assert.Equal(t, "launchpad", *rg.Tags["landingzone"], "LandingZone Tag is not correct")
	assert.Equal(t, "level0", *rg.Tags["level"], "Level Tag is not correct")
}

func TestLaunchpadResourceGroupHasKeyVault(t *testing.T) {
	t.Parallel()

	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	resourceGroupName := os.Getenv("RESOURCE_GROUP_NAME")
	keyVaultName := fmt.Sprintf("%s-kv-level0", os.Getenv("PREFIX"))

	kv := azure.GetKeyVault(t, resourceGroupName, keyVaultName, subscriptionId)

	assert.NotNil(t, kv, "KeyVault does not exists")
}

func TestLaunchpadResourceGroupHasStorageAccount(t *testing.T) {
	t.Parallel()

	subscriptionId := os.Getenv("ARM_SUBSCRIPTION_ID")
	resourceGroupName := os.Getenv("RESOURCE_GROUP_NAME")
	storageAccountName := fmt.Sprintf("%sstlevel0", os.Getenv("PREFIX"))

	exists := azure.StorageAccountExists(t, storageAccountName, resourceGroupName, subscriptionId)

	assert.True(t, exists, "Storage Account does not exists")
}

func TestLaunchpadKeyVaultHasSubscriptionIdSecret(t *testing.T) {
	t.Parallel()

	keyVaultName := fmt.Sprintf("%s-kv-level0", os.Getenv("PREFIX"))

	exists := azure.KeyVaultSecretExists(t, keyVaultName, "subscription-id")

	assert.True(t, exists, "Subscription Id Secret does not exists")
}

func TestLaunchpadKeyVaultHasTenantIdSecret(t *testing.T) {
	t.Parallel()

	keyVaultName := fmt.Sprintf("%s-kv-level0", os.Getenv("PREFIX"))

	exists := azure.KeyVaultSecretExists(t, keyVaultName, "tenant-id")

	assert.True(t, exists, "Tenant Id Secret does not exists")
}
}
