package module_test

import (
	"fmt"
	"testing"

	module "github.com/telia-oss/terraform-module-template/test"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModule(t *testing.T) {
	tests := []struct {
		description string
		directory   string
		name        string
		region      string
		expected    module.Expectations
	}{
		{
			description: "basic example",
			directory:   "../examples/basic",
			name:        fmt.Sprintf("module-basic-test-%s", random.UniqueId()),
			region:      "eu-west-1",
			expected:    module.Expectations{},
		},
		{
			description: "complete example",
			directory:   "../examples/complete",
			name:        fmt.Sprintf("module-complete-test-%s", random.UniqueId()),
			region:      "eu-west-1",
			expected:    module.Expectations{},
		},
	}

	for _, tc := range tests {
		tc := tc // Source: https://gist.github.com/posener/92a55c4cd441fc5e5e85f27bca008721
		t.Run(tc.description, func(t *testing.T) {
			t.Parallel()

			options := &terraform.Options{
				TerraformDir: tc.directory,

				Vars: map[string]interface{}{
					"name_prefix": tc.name,
					"region":      tc.region,
				},

				EnvVars: map[string]string{
					"AWS_DEFAULT_REGION": tc.region,
				},
			}

			defer terraform.Destroy(t, options)
			terraform.InitAndApply(t, options)

			tc.expected.NamePrefix = tc.name

			module.RunTestSuite(t,
				tc.region,
				terraform.Output(t, options, "name_prefix"),
				tc.expected,
			)
		})
	}
}
