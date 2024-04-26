//go:build tools

package rules_oapi_codegen

// This import is here to allow us to generate a go.mod file
import (
	_ "github.com/deepmap/oapi-codegen/v2/cmd/oapi-codegen"
)
