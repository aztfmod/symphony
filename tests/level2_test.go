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

func TestBastionSubNetInboundSecurityRules(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-AzureBastionSubnet", test.Prefix), test.SubscriptionID)
		actual := make([]string, 0)

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Inbound" {
				actual = append(actual, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, test.Config.BastionInboundRules, actual, fmt.Sprintf("Bastion Subnet doesn't have expected destination ports: %+q", test.Config.BastionInboundRules))
	}
}

func TestBastionSubNetOutboundSecurityRules(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-AzureBastionSubnet", test.Prefix), test.SubscriptionID)
		actual := make([]string, 0)

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Outbound" {
				actual = append(actual, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, test.Config.BastionOutboundRules, actual, fmt.Sprintf("Bastion Subnet doesn't have expected destination ports: %+q", test.Config.BastionOutboundRules))
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

func TestJumpboxInboundSecurityRules(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-jumpbox", test.Prefix), test.SubscriptionID)
		actual := make([]string, 0)

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Inbound" {
				actual = append(actual, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, test.Config.JumpboxInboundRules, actual, fmt.Sprintf("Jumpbox doesn't have expected destination ports: %+q", test.Config.JumpboxInboundRules))
	}
}

func TestJumpboxOutboundSecurityRules(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-jumpbox", test.Prefix), test.SubscriptionID)
		actual := make([]string, 0)

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Outbound" {
				actual = append(actual, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, test.Config.JumpboxOutboundRules, actual, fmt.Sprintf("Jumpbox doesn't have expected destination ports: %+q", test.Config.JumpboxOutboundRules))
	}
}

func TestPrivateEndpointsSecurityRulesCount(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-private_endpoints", test.Prefix), test.SubscriptionID)

		assert.Equal(t, 6, len(rules.SummarizedRules), fmt.Sprintf("Private Endpoints should have 6 rules, found %d", len(rules.SummarizedRules)))
	}
}

func TestPrivateEndpointsInboundSecurityRules(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-private_endpoints", test.Prefix), test.SubscriptionID)
		actual := make([]string, 0)

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Inbound" {
				actual = append(actual, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, test.Config.PrivateEndpointsInboundRules, actual, fmt.Sprintf("PrivateEndpoints doesn't have expected destination ports: %+q", test.Config.PrivateEndpointsInboundRules))
	}
}

func TestPrivateEndpointsOutboundSecurityRules(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	for iLoop := 1; iLoop <= 2; iLoop++ {
		rules := azure.GetAllNSGRules(t, fmt.Sprintf("%s-rg-vnet-hub-re%d", test.Prefix, iLoop), fmt.Sprintf("%s-nsg-private_endpoints", test.Prefix), test.SubscriptionID)
		actual := make([]string, 0)

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Outbound" {
				actual = append(actual, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, test.Config.PrivateEndpointsOutboundRules, actual, fmt.Sprintf("PrivateEndpoints doesn't have expected destination ports: %+q", test.Config.PrivateEndpointsOutboundRules))
	}
}
