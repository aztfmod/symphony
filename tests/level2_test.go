package caf_tests

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

func TestSharedServicesResourceGroupsExists(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'level' and tagValue eq 'level2'", nil)

	rgList := result.Values()

	actual := 0
	for _, rg := range rgList {
		if *rg.Tags["landingzone"] == "shared_services" && *rg.Tags["environment"] == test.Environment {
			actual++
		}
	}

	expected := 1

	assert.Equal(t, expected, actual, fmt.Sprintf("There must be %d resource group with 'level=level2' and 'environment=%s' tags, found %d", expected, test.Environment, actual))
}

func TestSharedServicesHasOneResourceGroupForSharedServices(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'shared_services'", nil)

	rgList := result.Values()

	actual := 0
	for _, rg := range rgList {
		if *rg.Tags["environment"] == test.Environment {
			actual++
		}
	}

	expected := 1

	assert.Equal(t, expected, actual, fmt.Sprintf("There must be only one resource group with 'landingzone=shared_services' and 'environment=%s' tags", test.Environment))
}

func TestSharedServicesHasRecoveryServiceVault(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'shared_services'", nil)

	rgList := result.Values()

	rg := rgList[0]

	exist := azure.RecoveryServicesVaultExists(t, fmt.Sprintf("%s-rsv-vaultre1", test.Prefix), *rg.Name, test.SubscriptionID)

	assert.True(t, exist, fmt.Sprintf("Expected Recovery Service Vault does not exists with '%s-rsv-vaultre1' name, under the resource group with 'landingzone=shared_services' tag", test.Prefix))
}

func TestSharedServicesHasTwoResourceGroupForNetworkingHub(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'level' and tagValue eq 'level2'", nil)

	rgList := result.Values()

	actual := 0
	for _, rg := range rgList {
		if *rg.Tags["landingzone"] == "networking_hub" && *rg.Tags["environment"] == test.Environment {
			actual++
		}
	}

	expected := 2

	assert.Equal(t, expected, actual, fmt.Sprintf("There must be %d resource group with 'landingzone=networking_hub' and 'environment=%s' tags, found %d", expected, test.Environment, actual))
}
