package caf_tests

import (
	"fmt"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLaunchpadResources(t *testing.T) {
	t.Parallel()

	fmt.Println(os.Getenv("TEST"))

	assert.True(t, true, false)
}
