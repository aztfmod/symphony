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
		if *rg.Tags["environment"] == test.Environment {
			actual++
		}
	}

	expected := 4

	assert.Equal(t, expected, actual, fmt.Sprintf("There must be %d resource group with 'level=level2' and 'environment=%s' tags, found %d", expected, test.Environment, actual))
}

func TestSharedServicesHasOneResourceGroupForSharedServices(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'shared_services'", nil)

	rgList := result.Values()

	expected := 1

	assert.Equal(t, expected, len(rgList), "Resource Group count does not match")
}

func TestSharedServicesHasRecoveryServiceVault(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'shared_services'", nil)

	rgList := result.Values()

	rg := rgList[0]

	exist := azure.RecoveryServicesVaultExists(t, fmt.Sprintf("%s-rsv-vaultre1", test.Prefix), *rg.Name, test.SubscriptionID)

	assert.True(t, exist, "Resource Group count does not match")
}

func TestSharedServicesHasTwoResourceGroupForNetworkingHub(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'networking_hub'", nil)

	rgList := result.Values()

	expected := 2

	assert.Equal(t, expected, len(rgList), "Resource Group count does not match")
}
