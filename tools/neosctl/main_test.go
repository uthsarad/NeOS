package main

import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestParseMirrors_Valid(t *testing.T) {
	tmpDir := t.TempDir()
	mirrorFile := filepath.Join(tmpDir, "mirrorlist")

	content := `
# NeOS mirrorlist test
# Some header comments

Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
Server = http://mirror.arizona.edu/archlinux/$repo/os/$arch
`
	if err := os.WriteFile(mirrorFile, []byte(content), 0644); err != nil {
		t.Fatalf("failed to write test mirrorlist: %v", err)
	}

	urls, err := parseMirrors(mirrorFile)
	if err != nil {
		t.Fatalf("expected parseMirrors to succeed, got error: %v", err)
	}

	// Regex in neosctl stops before '$' so base URL can be probed directly via HTTP HEAD
	expected := []string{
		"https://mirror.rackspace.com/archlinux/",
		"http://mirror.arizona.edu/archlinux/",
	}

	if len(urls) != len(expected) {
		t.Fatalf("expected %d urls, got %d", len(expected), len(urls))
	}

	for i, u := range urls {
		if u != expected[i] {
			t.Errorf("url[%d] = %q, expected %q", i, u, expected[i])
		}
	}
}

func TestParseMirrors_WhitespaceAndComments(t *testing.T) {
	tmpDir := t.TempDir()
	mirrorFile := filepath.Join(tmpDir, "mirrorlist_whitespace")

	content := `
# Disabled mirror:
# Server = https://disabled.example.com/$repo/os/$arch

	Server   =   https://tabbed.example.com/$repo/os/$arch
Server=https://tight.example.com/$repo/os/$arch
`
	if err := os.WriteFile(mirrorFile, []byte(content), 0644); err != nil {
		t.Fatalf("failed to write test file: %v", err)
	}

	urls, err := parseMirrors(mirrorFile)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	expected := []string{
		"https://tabbed.example.com/",
		"https://tight.example.com/",
	}

	if len(urls) != len(expected) {
		t.Fatalf("expected %d urls, got %d", len(expected), len(urls))
	}

	for i, u := range urls {
		if u != expected[i] {
			t.Errorf("url[%d] = %q, expected %q", i, u, expected[i])
		}
	}
}

func TestParseMirrors_TruncationAt15(t *testing.T) {
	tmpDir := t.TempDir()
	mirrorFile := filepath.Join(tmpDir, "mirrorlist_many")

	var b strings.Builder
	for i := 1; i <= 25; i++ {
		fmt.Fprintf(&b, "Server = https://mirror%02d.example.com/$repo/os/$arch\n", i)
	}

	if err := os.WriteFile(mirrorFile, []byte(b.String()), 0644); err != nil {
		t.Fatalf("failed to write file: %v", err)
	}

	urls, err := parseMirrors(mirrorFile)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if len(urls) != 15 {
		t.Errorf("expected 15 urls max, got %d", len(urls))
	}

	if urls[0] != "https://mirror01.example.com/" {
		t.Errorf("unexpected first url: %s", urls[0])
	}
	if urls[14] != "https://mirror15.example.com/" {
		t.Errorf("unexpected 15th url: %s", urls[14])
	}
}

func TestParseMirrors_NoServers(t *testing.T) {
	tmpDir := t.TempDir()
	mirrorFile := filepath.Join(tmpDir, "empty_mirrorlist")

	content := `
# No active servers here
# Server = https://commented.com
`
	if err := os.WriteFile(mirrorFile, []byte(content), 0644); err != nil {
		t.Fatalf("failed to write file: %v", err)
	}

	urls, err := parseMirrors(mirrorFile)
	if err == nil {
		t.Fatalf("expected error for empty mirrorlist, got urls: %v", urls)
	}
	if !strings.Contains(err.Error(), "no active Server URLs found") {
		t.Errorf("unexpected error message: %v", err)
	}
}

func TestParseMirrors_FileNotFound(t *testing.T) {
	_, err := parseMirrors("non_existent_mirrorlist_file.txt")
	if err == nil {
		t.Fatal("expected error for non-existent file, got nil")
	}
}

func TestBenchmarkMirrors(t *testing.T) {
	fastServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	defer fastServer.Close()

	slowServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		time.Sleep(30 * time.Millisecond)
		w.WriteHeader(http.StatusOK)
	}))
	defer slowServer.Close()

	failingServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusInternalServerError)
	}))
	defer failingServer.Close()

	urls := []string{
		slowServer.URL,
		fastServer.URL,
		failingServer.URL,
		"http://127.0.0.1:0", // unreachable
	}

	err := benchmarkMirrors(urls)
	if err != nil {
		t.Fatalf("benchmarkMirrors returned unexpected error: %v", err)
	}
}

func TestRunRankMirrors(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	}))
	defer server.Close()

	tmpDir := t.TempDir()
	mirrorFile := filepath.Join(tmpDir, "valid_mirrorlist")
	content := fmt.Sprintf("Server = %s\n", server.URL)
	if err := os.WriteFile(mirrorFile, []byte(content), 0644); err != nil {
		t.Fatalf("failed to write file: %v", err)
	}

	if err := runRankMirrors(mirrorFile); err != nil {
		t.Fatalf("runRankMirrors failed: %v", err)
	}

	// Non-existent file should error
	if err := runRankMirrors(filepath.Join(tmpDir, "missing")); err == nil {
		t.Fatal("expected runRankMirrors to fail on missing file")
	}
}

func TestRunInfoAndUsage(t *testing.T) {
	origStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	runInfo()
	printUsage()

	w.Close()
	os.Stdout = origStdout

	out, err := io.ReadAll(r)
	if err != nil {
		t.Fatalf("failed to read captured stdout: %v", err)
	}

	output := string(out)
	if !strings.Contains(output, "NeOS Sovereign Distribution Core") {
		t.Errorf("expected runInfo output to contain header, got: %s", output)
	}
	if !strings.Contains(output, "rank-mirrors") {
		t.Errorf("expected printUsage output to contain rank-mirrors command, got: %s", output)
	}
}
