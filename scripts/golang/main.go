package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	filePath := flag.String("file", "", "Path to the log file. Reads from stdin if not provided.")
	flag.Parse()

	var reader io.Reader

	if *filePath != "" {
		file, err := os.Open(*filePath)
		if err != nil {
			log.Fatalf("Error: Failed to open file: %v", err)
		}
		defer file.Close()
		reader = file
	} else {
		stat, _ := os.Stdin.Stat()
		if (stat.Mode() & os.ModeCharDevice) != 0 {
			fmt.Fprintln(os.Stderr, "Reading from stdin. Pipe data to the program or use the --file flag.")
			fmt.Fprintln(os.Stderr, "Press Ctrl+D (or Ctrl+Z on Windows) to end input.")
		}
		reader = os.Stdin
	}

	results := AggregateIPs(reader)

	for _, result := range results {
		fmt.Printf("%d %s\n", result.Count, result.IP)
	}
}
