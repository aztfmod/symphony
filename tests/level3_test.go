package caf_tests

import (
	"context"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

func TestThereAreTwoResourceGroupsForNetworkingHub(t *testing.T) {
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

func TestVirtualNetworksAreInDifferentRegions(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	vnet1, _ := azure.GetVirtualNetworkE(fmt.Sprintf("%s-vnet-hub-re1", test.Prefix), fmt.Sprintf("%s-rg-vnet-hub-re1", test.Prefix), test.SubscriptionID)

	vnet2, _ := azure.GetVirtualNetworkE(fmt.Sprintf("%s-vnet-hub-re2", test.Prefix), fmt.Sprintf("%s-rg-vnet-hub-re2", test.Prefix), test.SubscriptionID)

	assert.NotEqual(t, *vnet1.Location, *vnet2.Location, "Virtual Networks in the 'landingzone=networking_hub' resource groups should provisioned in different regions")
}

func TestBastionSubNetSecurityRulesCount(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-AzureBastionSubnet", test.Prefix), test.SubscriptionID)

		assert.Equal(t, 12, len(rules.SummarizedRules), fmt.Sprintf("Bastion Subnet should have 12 rules, found %d", len(rules.SummarizedRules)))
	}
}

func TestJumpboxSecurityRulesCount(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-jumpbox", test.Prefix), test.SubscriptionID)

		assert.Equal(t, 7, len(rules.SummarizedRules), fmt.Sprintf("Jumpbox should have 7 rules, found %d", len(rules.SummarizedRules)))
	}
}
