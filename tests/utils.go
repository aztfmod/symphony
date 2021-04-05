package caf_tests

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

type LandingZone struct {
	Level              int
	ResourceGroupName  string
	KeyVaultName       string
	StorageAccountName string
}

type TestStructure struct {
	Environment    string
	Prefix         string
	SubscriptionID string
	Location       string
	LandingZones   []LandingZone
	Config         Config
}

type Config struct {
	Location                      string   `json:"location"`
	BastionInboundRules           []string `json:"bastionInboundRules"`
	BastionOutboundRules          []string `json:"bastionOutboundRules"`
	JumpboxInboundRules           []string `json:"jumpboxInboundRules"`
	JumpboxOutboundRules          []string `json:"jumpboxOutboundRules"`
	PrivateEndpointsInboundRules  []string `json:"privateEndpointsInboundRules"`
	PrivateEndpointsOutboundRules []string `json:"privateEndpointsOutboundRules"`
}

// Data-Driven Testing approach implemented
// https://en.wikipedia.org/wiki/Data-driven_testing
func prepareTestTable() TestStructure {
	prefix := os.Getenv("PREFIX")

	test := TestStructure{
		Prefix:         prefix,
		SubscriptionID: os.Getenv("ARM_SUBSCRIPTION_ID"),
		Environment:    os.Getenv("ENVIRONMENT"),
		LandingZones:   make([]LandingZone, 0),
	}

	jsonFile, err := os.Open("config.json")
	if err != nil {
		fmt.Println(err)
	}
	defer jsonFile.Close()

	byteValue, _ := ioutil.ReadAll(jsonFile)

	json.Unmarshal(byteValue, &test.Config)

	for iLoop := 0; iLoop < 4; iLoop++ {
		test.LandingZones = append(test.LandingZones, LandingZone{
			Level:              iLoop,
			ResourceGroupName:  fmt.Sprintf("%s-rg-launchpad-level%d", prefix, iLoop),
			KeyVaultName:       fmt.Sprintf("%s-kv-level%d", prefix, iLoop),
			StorageAccountName: fmt.Sprintf("%sstlevel%d", prefix, iLoop),
		})
	}

	return test
}
