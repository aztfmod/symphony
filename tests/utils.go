package caf_tests

import (
	"fmt"
	"os"
	"strings"
)

type LandingZone struct {
	Level              int
	ResourceGroupName  string
	KeyVaultName       string
	StorageAccountName string
}

type TestStructure struct {
	Environment                      string
	Prefix                           string
	SubscriptionID                   string
	Location                         string
	LandingZones                     []LandingZone
}

// Data-Driven Testing approach implemented
// https://en.wikipedia.org/wiki/Data-driven_testing
func prepareTestTable() TestStructure {
	prefix := os.Getenv("PREFIX")

	test := TestStructure{
		Prefix:                           prefix,
		SubscriptionID:                   os.Getenv("ARM_SUBSCRIPTION_ID"),
		Environment:                      os.Getenv("ENVIRONMENT"),
		Location:                         os.Getenv("LOCATION"),
		LandingZones:                     make([]LandingZone, 0),
	}

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
