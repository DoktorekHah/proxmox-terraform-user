package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestProxmoxUserBasic tests basic user creation
func TestProxmoxUserBasic(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",
		NoColor:      true,
	})

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	userOutput := terraform.OutputMap(t, terraformOptions, "user")

	// Assert that the output map is not empty
	assert.NotEmpty(t, userOutput, "User output should not be empty")

	// Check that expected keys exist in the output
	assert.Contains(t, userOutput, "id", "User should contain 'id' key")
	assert.Contains(t, userOutput, "username", "User should contain 'username' key")
}

// TestProxmoxUserMultiple tests multiple user creation
func TestProxmoxUserMultiple(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/multiple_users",
		NoColor:      true,
	})

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	output := terraform.OutputJson(t, terraformOptions, "users")

	// Assert that the output is not empty
	assert.NotEmpty(t, output, "Users output should not be empty")
}

// TestProxmoxUserPlanOnly tests that terraform plan runs without errors
func TestProxmoxUserPlanOnly(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		NoColor:      true,
		PlanFilePath: "./plan",
	}

	// Run "terraform init" and "terraform plan"
	terraform.Init(t, terraformOptions)

	// This will save the plan to the PlanFilePath
	exitCode := terraform.Plan(t, terraformOptions)

	// Assert that the plan was successful (exit code 0 or 2)
	// Exit code 2 means there are changes to apply (expected)
	assert.Contains(t, []int{0, 2}, exitCode, "Terraform plan should complete successfully")
}

// TestProxmoxUserValidation tests input validation
func TestProxmoxUserValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/basic",
		NoColor:      true,
	}

	// Run "terraform init" to install providers
	terraform.Init(t, terraformOptions)

	// Run "terraform validate" to check configuration syntax
	terraform.Validate(t, terraformOptions)
}
