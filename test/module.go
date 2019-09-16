package module

import (
	"testing"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
)

// Expectations for the test suite.
type Expectations struct {
	NamePrefix string
}

// RunTestSuite for the module.
func RunTestSuite(t *testing.T, region, namePrefix string, expected Expectations) {
	if expected.NamePrefix != namePrefix {
		t.Fatalf("expected: %s, got: %s", expected.NamePrefix, namePrefix)
	}
}

// NewSession for AWS.
func NewSession(t *testing.T, region string) *session.Session {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		t.Fatalf("failed to create new AWS session: %s", err)
	}
	return sess
}
