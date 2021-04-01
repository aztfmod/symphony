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
