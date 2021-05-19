package caf_tests

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	terraform "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/joho/godotenv"
)

type LandingZone struct {
	Level              int
	ResourceGroupName  string
	KeyVaultName       string
	StorageAccountName string
}

type TestStructure struct {
	Environment      string
	Prefix           string
	SubscriptionID   string
	Location         string
	LandingZones     []LandingZone
	Config           Config
	StateFilePath    string
	TerraformOptions *terraform.Options
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
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found")
	}

	prefix := os.Getenv("PREFIX")

	test := TestStructure{
		Prefix:         prefix,
		SubscriptionID: os.Getenv("ARM_SUBSCRIPTION_ID"),
		Environment:    os.Getenv("ENVIRONMENT"),
		StateFilePath:  os.Getenv("STATE_FILE_PATH"),
		LandingZones:   make([]LandingZone, 0),
	}

	options := &terraform.Options{
		TerraformDir: test.StateFilePath,
	}
	test.TerraformOptions = options

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

/* CAF OUTPUT Helpers */
func getLandingZoneKey(outputJson string) string {
	var result map[string]interface{}
	json.Unmarshal([]byte(outputJson), &result)
	launchpad := result["launchpad"].(map[string]interface{})
	client_config := launchpad["client_config"].(map[string]interface{})
	landing_zone_key := client_config["landingzone_key"]
	return landing_zone_key.(string)
}

func getResourceGroups(outputJson string) map[string](map[string]interface{}) {
	var result map[string]interface{}
	json.Unmarshal([]byte(outputJson), &result)
	launchpad := result["launchpad"].(map[string]interface{})
	resourceGroups := launchpad["resource_groups"].(map[string]interface{})

	var m map[string](map[string]interface{})
	m = make(map[string](map[string]interface{}))
	for key, resourceGroup := range resourceGroups {
		rg := resourceGroup.(map[string](interface{}))
		m[key] = rg
	}
	return m
}
