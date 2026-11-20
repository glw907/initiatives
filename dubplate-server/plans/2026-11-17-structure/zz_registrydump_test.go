package main

import (
	"crypto/sha256"
	"fmt"
	"reflect"
	"strings"
	"testing"
)

// TestRegistryDump prints every declaration in the production registry,
// in registration order, with each field that is not a function. The
// structure round runs it at a pass's base and head: the two hashes must
// match. It is a throwaway proof and is never committed.
func TestRegistryDump(t *testing.T) {
	reg := newProductionRegistry()
	var b strings.Builder
	dump := func(family string, items any) {
		v := reflect.ValueOf(items)
		for i := range v.Len() {
			item := v.Index(i)
			fmt.Fprintf(&b, "%s[%d]", family, i)
			for f := range item.NumField() {
				if item.Field(f).Kind() == reflect.Func {
					fmt.Fprintf(&b, " %s=func(nil=%t)", item.Type().Field(f).Name, item.Field(f).IsNil())
					continue
				}
				fmt.Fprintf(&b, " %s=%q", item.Type().Field(f).Name, fmt.Sprint(item.Field(f).Interface()))
			}
			b.WriteByte('\n')
		}
	}
	dump("wall", reg.OwnedWall())
	dump("reserved", reg.ReservedClasses())
	dump("integration", reg.IntegrationClasses())
	dump("threshold", reg.Thresholds())
	dump("identity-source", reg.IdentitySources())
	dump("setting", reg.Settings())
	dump("rule", reg.CorrelatedRules())
	t.Logf("registry dump: %d lines, sha256 %x", strings.Count(b.String(), "\n"), sha256.Sum256([]byte(b.String())))
	if testing.Verbose() {
		t.Log("\n" + b.String())
	}
}
