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

	var top int32 = 100

	result, _ := client.List(context.Background(), "tagName eq 'level' and tagValue eq 'level1'", &top)

	rgList := result.Values()

	expected := 1

	assert.Equal(t, expected, len(rgList), "Resource Group count does not match")
}
