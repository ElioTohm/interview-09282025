package main

import (
	"bufio"
	"io"
	"regexp"
	"sort"
	"strings"
)

// IPCount holds an IP address and its associated frequency count.
type IPCount struct {
	IP    string
	Count int
}

// Pre-compiling the regex improves performance as it avoids re-compiling on every line.
var ipv4Regex = regexp.MustCompile(`^([0-9]{1,3}\.){3}[0-9]{1,3}$`)

// AggregateIPs reads log data from an io.Reader, counts the frequency of each
// valid IP address, and returns the results sorted in descending order of frequency.
func AggregateIPs(reader io.Reader) []IPCount {
	// Use a map to store the frequency of each IP address.
	counts := make(map[string]int)
	scanner := bufio.NewScanner(reader)

	// Read the input line by line.
	for scanner.Scan() {
		fields := strings.Fields(scanner.Text())

		// A valid line must have at least two fields. This also skips blank lines.
		if len(fields) < 2 {
			continue
		}

		ip := fields[1]

		// Use the regex to validate that the second field is an IPv4 address.
		if ipv4Regex.MatchString(ip) {
			counts[ip]++
		}
	}

	// Convert the map to a slice of IPCount structs for sorting.
	var result []IPCount
	for ip, count := range counts {
		result = append(result, IPCount{IP: ip, Count: count})
	}

	// Sort the slice in descending order based on the Count.
	sort.Slice(result, func(i, j int) bool {
		return result[i].Count > result[j].Count
	})

	return result
}
