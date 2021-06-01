// +build level3

package caf_tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAKSClusterExists(t *testing.T) {
	t.Parallel()

	tfState := NewTerraformState(t, "cluster_aks")
	clusters := tfState.GetAKSClusters()

	for _, cluster := range clusters {
		name := cluster.GetString("cluster_name")
		resourceGroupName := cluster.GetString("resource_group_name")

		cluster, err := azure.GetManagedClusterE(t, resourceGroupName, name, tfState.SubscriptionID)
		require.NoError(t, err)
		assert.NotNil(t, cluster)
	}
}

func TestAKSClusterOnlyOneAgentCount(t *testing.T) {
	t.Parallel()

	tfState := NewTerraformState(t, "cluster_aks")
	clusters := tfState.GetAKSClusters()
	expectedAgentCount := 1

	for _, cluster := range clusters {
		name := cluster.GetString("cluster_name")
		resourceGroupName := cluster.GetString("resource_group_name")

		cluster, err := azure.GetManagedClusterE(t, resourceGroupName, name, tfState.SubscriptionID)
		require.NoError(t, err)
		actualCount := *(*cluster.ManagedClusterProperties.AgentPoolProfiles)[0].Count
		assert.Equal(t, int32(expectedAgentCount), actualCount)
	}
}
