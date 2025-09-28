package main

import (
	"reflect"
	"strings"
	"testing"
)

func TestAggregateIPs(t *testing.T) {
	// A multi-line string simulates a log file, including valid, malformed, and blank lines.
	logData := `
[29/Sep/2021:10:20:48+0100] 192.168.1.1 /
[29/Sep/2021:10:21:12+0100] 10.0.0.1 /api
This is a malformed line
[29/Sep/2021:10:21:15+0100] 192.168.1.1 /static

[29/Sep/2021:10:22:05+0100] 10.0.0.1 /api/v2
[29/Sep/2021:10:23:30+0100] 192.168.1.1 /img.png
[29/Sep/2021:10:24:00+0100] 172.16.0.1 /login
`
	reader := strings.NewReader(logData)

	// Define the expected output, pre-sorted.
	expected := []IPCount{
		{IP: "192.168.1.1", Count: 3},
		{IP: "10.0.0.1", Count: 2},
		{IP: "172.16.0.1", Count: 1},
	}

	// Get the actual result from the function.
	actual := AggregateIPs(reader)

	// reflect.DeepEqual provides a robust way to compare complex data structures.
	if !reflect.DeepEqual(actual, expected) {
		t.Errorf("Test failed: expected %v, got %v", expected, actual)
	}
}

func TestAggregateIPsEmptyInput(t *testing.T) {
	reader := strings.NewReader("")
	actual := AggregateIPs(reader)
	if len(actual) != 0 {
		t.Errorf("Test failed on empty input: expected an empty slice, got %v", actual)
	}
}
