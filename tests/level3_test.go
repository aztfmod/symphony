package caf_tests

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestAKSClusterAgentCount(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()
	expectedClusterName := fmt.Sprintf("%s-aks-akscluster-re1-001", test.Prefix)
	expectedResourceGroupName := fmt.Sprintf("%s-rg-aks-re1", test.Prefix)
	expectedAgentCount := 1

	cluster, err := azure.GetManagedClusterE(t, expectedResourceGroupName, expectedClusterName, "")
	require.NoError(t, err)
	actualCount := *(*cluster.ManagedClusterProperties.AgentPoolProfiles)[0].Count
	assert.Equal(t, int32(expectedAgentCount), actualCount)
}
