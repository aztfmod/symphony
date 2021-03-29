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

	var top int32 = 100

	result, _ := client.List(context.Background(), "tagName eq 'level' and tagValue eq 'level2'", &top)

	rgList := result.Values()

	expected := 4

	assert.Equal(t, expected, len(rgList), "Resource Group count does not match")
}

func TestSharedServicesHasOneResourceGroupForSharedServices(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	var top int32 = 100

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'shared_services'", &top)

	rgList := result.Values()

	expected := 1

	assert.Equal(t, expected, len(rgList), "Resource Group count does not match")
}

func TestSharedServicesHasRecoveryServiceVault(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	var top int32 = 100

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'shared_services'", &top)

	rgList := result.Values()

	rg := rgList[0]

	exist := azure.RecoveryServicesVaultExists(t, fmt.Sprintf("%s-rsv-vaultre1", test.Prefix), *rg.Name, test.SubscriptionID)

	assert.True(t, exist, "Resource Group count does not match")
}

func TestSharedServicesHasTwoResourceGroupForNetworkingHub(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	var top int32 = 100

	result, _ := client.List(context.Background(), "tagName eq 'landingzone' and tagValue eq 'networking_hub'", &top)

	rgList := result.Values()

	expected := 2

	assert.Equal(t, expected, len(rgList), "Resource Group count does not match")
}
