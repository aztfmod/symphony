// +build level2,networking

package caf_tests

import (
	"context"
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestThereAreTwoResourceGroupsForNetworkingHub(t *testing.T) {
	t.Parallel()

	tfState := NewTerraformState(t, "networking_hub")
	resourceGroups := tfState.GetResourceGroups()
	client, _ := azure.GetResourceGroupClientE(tfState.SubscriptionID)

	for _, resourceGroup := range resourceGroups {
		name := resourceGroup.GetName()

		actual_rc, err := client.Get(context.Background(), name)
		require.NoError(t, err)

		assert.Equal(t, *actual_rc.Tags["landingzone"], tfState.GetLandingZoneKey())
		assert.Equal(t, *actual_rc.Tags["environment"], tfState.Environment)
		assert.Equal(t, *actual_rc.Tags["level"], resourceGroup.GetLevel())
	}
}

func TestVirtualNetworksAreInDifferentRegions(t *testing.T) {
	t.Parallel()
	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	var locations []string
	for _, vnet := range vNets {
		vn, err := azure.GetVirtualNetworkE(vnet.GetName(), vnet.GetString("resource_group_name"), tfState.SubscriptionID)
		require.NoError(t, err)

		locations = append(locations, *vn.Location)
	}

	assert.NotEqual(t, locations[0], locations[1], fmt.Sprintf("Virtual Networks in the 'landingzone=%s' resource groups should provisioned in different regions", tfState.GetLandingZoneKey()))
}

func TestBastionSubNetSecurityRulesCount(t *testing.T) {
	t.Parallel()

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-AzureBastionSubnet", prefix[0]), tfState.SubscriptionID)

		assert.Equal(t, 12, len(rules.SummarizedRules), fmt.Sprintf("Bastion Subnet should have 12 rules, found %d", len(rules.SummarizedRules)))
	}
}

func TestBastionSubNetInboundSecurityRules(t *testing.T) {
	t.Parallel()
	expected_port_rage := []string{"*", "*", "*", "4443", "443", "135"}

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-AzureBastionSubnet", prefix[0]), tfState.SubscriptionID)
		var actual_port_rage []string

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Inbound" {
				actual_port_rage = append(actual_port_rage, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, expected_port_rage, actual_port_rage, fmt.Sprintf("Bastion Subnet doesn't have expected destination ports: %+q", expected_port_rage))
	}
}

func TestBastionSubNetOutboundSecurityRules(t *testing.T) {
	t.Parallel()

	expected_port_rage := []string{"*", "*", "*", "443", "3389", "22"}

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-AzureBastionSubnet", prefix[0]), tfState.SubscriptionID)
		var actual_port_rage []string

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Outbound" {
				actual_port_rage = append(actual_port_rage, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, expected_port_rage, actual_port_rage, fmt.Sprintf("Bastion Subnet doesn't have expected destination ports: %+q", expected_port_rage))
	}
}

func TestJumpboxSecurityRulesCount(t *testing.T) {
	t.Parallel()

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-jumpbox", prefix[0]), tfState.SubscriptionID)

		assert.Equal(t, 7, len(rules.SummarizedRules), fmt.Sprintf("Jumpbox Subnet should have 7 rules, found %d", len(rules.SummarizedRules)))
	}
}

func TestJumpboxInboundSecurityRules(t *testing.T) {
	t.Parallel()

	expected_port_rage := []string{"*", "*", "*", "22"}

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-jumpbox", prefix[0]), tfState.SubscriptionID)
		var actual_port_rage []string

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Inbound" {
				actual_port_rage = append(actual_port_rage, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, expected_port_rage, actual_port_rage, fmt.Sprintf("Jumpbox Subnet doesn't have expected destination ports: %+q", expected_port_rage))
	}
}

func TestJumpboxOutboundSecurityRules(t *testing.T) {
	t.Parallel()

	expected_port_rage := []string{"*", "*", "*"}

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-jumpbox", prefix[0]), tfState.SubscriptionID)
		var actual_port_rage []string

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Outbound" {
				actual_port_rage = append(actual_port_rage, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, expected_port_rage, actual_port_rage, fmt.Sprintf("Jumpbox Subnet doesn't have expected destination ports: %+q", expected_port_rage))
	}
}

func TestPrivateEndpointsSecurityRulesCount(t *testing.T) {
	t.Parallel()

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-private_endpoints", prefix[0]), tfState.SubscriptionID)

		assert.Equal(t, 6, len(rules.SummarizedRules), fmt.Sprintf("private_endpoints Subnet should have 6 rules, found %d", len(rules.SummarizedRules)))
	}
}

func TestPrivateEndpointsInboundSecurityRules(t *testing.T) {
	t.Parallel()

	expected_port_rage := []string{"*", "*", "*"}

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-private_endpoints", prefix[0]), tfState.SubscriptionID)
		var actual_port_rage []string

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Inbound" {
				actual_port_rage = append(actual_port_rage, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, expected_port_rage, actual_port_rage, fmt.Sprintf("PrivateEndpoints Subnet doesn't have expected destination ports: %+q", expected_port_rage))
	}
}

func TestPrivateEndpointsOutboundSecurityRules(t *testing.T) {
	t.Parallel()

	expected_port_rage := []string{"*", "*", "*"}

	tfState := NewTerraformState(t, "networking_hub")
	vNets := tfState.GetVNets()

	for _, vnet := range vNets {
		prefix := strings.Split(vnet.GetString("resource_group_name"), "-")
		rules := azure.GetAllNSGRules(t, vnet.GetString("resource_group_name"), fmt.Sprintf("%s-nsg-private_endpoints", prefix[0]), tfState.SubscriptionID)
		var actual_port_rage []string

		for _, rule := range rules.SummarizedRules {
			if rule.Direction == "Outbound" {
				actual_port_rage = append(actual_port_rage, rule.DestinationPortRange)
			}
		}

		assert.ElementsMatch(t, expected_port_rage, actual_port_rage, fmt.Sprintf("PrivateEndpoints Subnet doesn't have expected destination ports: %+q", expected_port_rage))
	}
}
