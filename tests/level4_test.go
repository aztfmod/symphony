package caf_tests

import (
	"crypto/tls"
	"fmt"
	"testing"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
)

func TestArgoCDLocalPortForwardWorks(t *testing.T) {
	t.Parallel()

	// https: //github.com/aztfmod/terratest/blob/master/test/helm_basic_example_integration_test.go
	// Note this test expects that the port forward to the aks cluster is established before running the test. See tests readme

	endpoint := "localhost:9090"
	tlsConfig := tls.Config{}
	tlsConfig.InsecureSkipVerify = true

	http_helper.HttpGetWithCustomValidation(
		t,
		fmt.Sprintf("http://%s", endpoint),
		&tlsConfig,
		func(statusCode int, body string) bool {
			return statusCode == 200
		},
	)
}
