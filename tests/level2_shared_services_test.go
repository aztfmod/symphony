// +build level2,sharedsvc

package caf_tests

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

func TestSharedServicesLandingZoneKey(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "shared_services")

	//act
	landingZoneKey := tfState.GetLandingZoneKey()

	//assert
	assert.Equal(t, "shared_services", landingZoneKey)
}

func TestSharedServicesPrimaryResourceGroupsExists(t *testing.T) {
	//arrange
	t.Parallel()

	tfState := NewTerraformState(t, "shared_services")
	resourceGroups := tfState.GetResourceGroups()

	if resourceGroup, ok := resourceGroups["primary"]; ok {
		name := resourceGroup.GetName()
		exists := azure.ResourceGroupExists(t, name, tfState.SubscriptionID)
		assert.True(t, exists, fmt.Sprintf("Resource group (%s) does not exist", name))
	} else {
		t.FailNow()
	}
}

func TestSharedServicesStateContainsOnlyOneResourceGroup(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "shared_services")

	//act
	resourceGroups := tfState.GetResourceGroups()

	//assert
	assert.Equal(t, 1, len(resourceGroups), "More than one shared services resource group found in state.")
}

func TestSharedServicesContainsOnlyOneResourceGroup(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "shared_services")
	client, _ := azure.GetResourceGroupClientE(tfState.SubscriptionID)

	//act
	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'shared_services'", nil)
	rgList := result.Values()

	foundResourceGroup := false
	for _, rg := range rgList {
		if *rg.Tags["environment"] == tfState.Environment {
			foundResourceGroup = true
		}
	}
	//assert
	assert.Equal(t, true, foundResourceGroup, fmt.Sprintf("Shared Services resource group for environment %s was not found", tfState.Environment))
}

func TestSharedServicesHasRecoveryServiceVault(t *testing.T) {
	t.Parallel()
	tfState := NewTerraformState(t, "shared_services")
	resourceGroups := tfState.GetResourceGroups()
	recoveryVaults := tfState.GetRecoveryVaults()

	var recoveryVaultName string
	if recoveryVault, ok := recoveryVaults["asr1"]; ok {
		recoveryVaultName = recoveryVault.GetName()
	} else {
		t.FailNow()
	}

	if resourceGroup, ok := resourceGroups["primary"]; ok {
		resourceGroupName := resourceGroup.GetName()
		exist := azure.RecoveryServicesVaultExists(t, recoveryVaultName, resourceGroupName, tfState.SubscriptionID)
		assert.True(t, exist, fmt.Sprintf("Expected Recovery Service Vault '%s' does not exist", recoveryVaultName))
	} else {
		t.FailNow()
	}
}
