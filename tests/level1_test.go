// +build level1

package caf_tests

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFoundationsLandingZoneKey(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "caf_foundations")

	//act
	landingZoneKey := tfState.GetLandingZoneKey()

	//assert
	assert.Equal(t, "caf_foundations", landingZoneKey)
}

func TestFoundationClientConfigSubscriptionId(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "caf_foundations")

	//act
	client_config := tfState.GetClientConfig()

	//assert
	assert.Equal(t, tfState.SubscriptionID, client_config["subscription_id"].(string))
}

func TestFoundationGlobalSettingsEnvironment(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "caf_foundations")

	//act
	global_settings := tfState.GetGlobalSettings()

	//assert
	assert.Equal(t, tfState.Environment, global_settings["environment"].(string))
}

func TestFoundationGlobalSettingsEnvironment(t *testing.T) {
	//arrange
	t.Parallel()
	tfState := NewTerraformState(t, "caf_foundations")

	//act
	global_settings := tfState.GetGlobalSettings()

	//assert
	assert.Equal(t, tfState.Environment, global_settings["environment"].(string))
}
