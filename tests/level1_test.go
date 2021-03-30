package caf_tests

import (
	"context"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/assert"
)

func TestFoundationResourceGroupsDoesNotExist(t *testing.T) {
	t.Parallel()

	test := prepareTestTable()

	client, _ := azure.GetResourceGroupClientE(test.SubscriptionID)

	result, _ := client.List(context.Background(), "tagName eq 'level' and tagValue eq 'level1'", nil)

	rgList := result.Values()

	actual := 0
	for _, rg := range rgList {
		if *rg.Tags["environment"] == test.Environment {
			actual++
		}
	}

	expected := 1

	assert.Equal(t, expected, actual, "Resource Group count does not match")
}
