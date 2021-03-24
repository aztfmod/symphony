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
	t.Parallel()

	fmt.Println(os.Getenv("TEST"))

	assert.True(t, true, false)
}
