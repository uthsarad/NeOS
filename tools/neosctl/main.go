package main

import (
	"bufio"
	"context"
	"crypto/tls"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"sync"
	"time"
)

const (
	Version     = "2026.08.18"
	AppName     = "neosctl"
	ColorCyan   = "\033[1;36m"
	ColorGreen  = "\033[1;32m"
	ColorYellow = "\033[1;33m"
	ColorRed    = "\033[1;31m"
	ColorBold   = "\033[1m"
	ColorReset  = "\033[0m"
)

type MirrorResult struct {
	URL     string
	Latency time.Duration
	Err     error
}

func main() {
	if len(os.Args) < 2 {
		printUsage()
		os.Exit(0)
	}

	command := os.Args[1]
	switch command {
	case "audit":
		profilePath := "profile"
		if len(os.Args) >= 3 {
			profilePath = os.Args[2]
		}
		if err := runAudit(profilePath); err != nil {
			fmt.Fprintf(os.Stderr, "%s❌ Audit Failed:%s %v\n", ColorRed, ColorReset, err)
			os.Exit(1)
		}
		fmt.Printf("%s✅ NeOS Profile Audit Passed via Go!%s\n", ColorGreen, ColorReset)

	case "rank-mirrors":
		mirrorlistPath := "profile/airootfs/etc/pacman.d/neos-mirrorlist"
		if len(os.Args) >= 3 {
			mirrorlistPath = os.Args[2]
		}
		if err := runRankMirrors(mirrorlistPath); err != nil {
			fmt.Fprintf(os.Stderr, "%s❌ Mirror ranking failed:%s %v\n", ColorRed, ColorReset, err)
			os.Exit(1)
		}

	case "info":
		runInfo()

	case "version", "-v", "--version":
		fmt.Printf("%s%s%s version %s (Go runtime)\n", ColorCyan, AppName, ColorReset, Version)

	case "help", "-h", "--help":
		printUsage()

	default:
		fmt.Fprintf(os.Stderr, "%sUnknown command:%s %s\n\n", ColorRed, ColorReset, command)
		printUsage()
		os.Exit(1)
	}
}

func printUsage() {
	fmt.Printf("%s%s — Next Evolution Operating System CLI Utility%s\n", ColorCyan, AppName, ColorReset)
	fmt.Printf("Version: %s\n\n", Version)
	fmt.Println("USAGE:")
	fmt.Println("  neosctl <command> [arguments]")
	fmt.Println("\nCOMMANDS:")
	fmt.Println("  audit [path]         Validate archiso profile hygiene and package completeness")
	fmt.Println("  rank-mirrors [file]  Concurrently benchmark and rank Arch Linux mirrors")
	fmt.Println("  info                 Display NeOS distribution metadata and system information")
	fmt.Println("  version              Display neosctl version")
	fmt.Println("  help                 Show this help message")
}

func runInfo() {
	fmt.Printf("%s=================================================================%s\n", ColorCyan, ColorReset)
	fmt.Printf("%s🌸 NeOS Sovereign Distribution Core%s\n", ColorBold, ColorReset)
	fmt.Printf("%s=================================================================%s\n", ColorCyan, ColorReset)
	fmt.Printf("  • Distribution:  %sNeOS (Next Evolution Operating System)%s\n", ColorGreen, ColorReset)
	fmt.Printf("  • Base Platform: Arch Linux (Rolling)\n")
	fmt.Printf("  • Desktop Env:   KDE Plasma 6 (Optimized for Windows Migrants)\n")
	fmt.Printf("  • Package Engine: pacman + Btrfs Snapshots + Chaotic-AUR\n")
	fmt.Printf("  • Core Version:  %s\n", Version)
	fmt.Printf("%s=================================================================%s\n", ColorCyan, ColorReset)
}

func runAudit(root string) error {
	fmt.Printf("%s[neosctl::audit]%s Scanning profile at '%s'...\n", ColorCyan, ColorReset, root)

	requiredFiles := []string{
		"profiledef.sh",
		"pacman.conf",
		"grub/grub.cfg",
		"syslinux/syslinux.cfg",
		"packages.x86_64",
		"airootfs/etc/pacman.d/neos-mirrorlist",
		"airootfs/etc/pacman.d/chaotic-mirrorlist",
	}

	for _, file := range requiredFiles {
		fullPath := filepath.Join(root, file)
		if _, err := os.Stat(fullPath); os.IsNotExist(err) {
			return fmt.Errorf("required file missing: %s", fullPath)
		}
	}

	// Audit package list
	pkgFile := filepath.Join(root, "packages.x86_64")
	f, err := os.Open(pkgFile)
	if err != nil {
		return err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	pkgSet := make(map[string]struct{})
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		if _, exists := pkgSet[line]; exists {
			return fmt.Errorf("duplicate package in packages.x86_64: %s", line)
		}
		pkgSet[line] = struct{}{}
	}

	essentialPkgs := []string{"base", "mkinitcpio", "mkinitcpio-archiso", "networkmanager", "sudo", "vim"}
	for _, p := range essentialPkgs {
		if _, ok := pkgSet[p]; !ok {
			return fmt.Errorf("missing essential package in packages.x86_64: %s", p)
		}
	}

	// Verify kernel is present
	_, hasKernel := pkgSet["linux"]
	_, hasLts := pkgSet["linux-lts"]
	_, hasZen := pkgSet["linux-zen"]
	if !hasKernel && !hasLts && !hasZen {
		return fmt.Errorf("packages.x86_64 must include a kernel (linux, linux-lts, or linux-zen)")
	}

	fmt.Printf("  ✓ Verified %d unique packages.\n", len(pkgSet))
	fmt.Printf("  ✓ All required profile files and kernel invariants confirmed.\n")
	return nil
}

func runRankMirrors(path string) error {
	fmt.Printf("%s[neosctl::rank-mirrors]%s Parsing %s...\n", ColorCyan, ColorReset, path)
	f, err := os.Open(path)
	if err != nil {
		return err
	}
	defer f.Close()

	var urls []string
	serverRegex := regexp.MustCompile(`^[ \t]*Server[ \t]*=[ \t]*(https?://[^\s$]+)`)
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		matches := serverRegex.FindStringSubmatch(line)
		if len(matches) > 1 {
			u := matches[1]
			urls = append(urls, u)
			if len(urls) >= 15 {
				break
			}
		}
	}

	if len(urls) == 0 {
		return fmt.Errorf("no active Server URLs found in %s", path)
	}

	fmt.Printf("Benchmarking %d top mirrors concurrently with Go workers...\n", len(urls))

	results := make(chan MirrorResult, len(urls))
	var wg sync.WaitGroup

	client := &http.Client{
		Timeout: 3 * time.Second,
		Transport: &http.Transport{
			TLSClientConfig: &tls.Config{InsecureSkipVerify: false},
		},
	}

	for _, u := range urls {
		wg.Add(1)
		go func(url string) {
			defer wg.Done()
			ctx, cancel := context.WithTimeout(context.Background(), 2500*time.Millisecond)
			defer cancel()

			req, err := http.NewRequestWithContext(ctx, "HEAD", url, nil)
			if err != nil {
				results <- MirrorResult{URL: url, Err: err}
				return
			}
			start := time.Now()
			resp, err := client.Do(req)
			if err != nil {
				results <- MirrorResult{URL: url, Err: err}
				return
			}
			resp.Body.Close()
			latency := time.Since(start)
			results <- MirrorResult{URL: url, Latency: latency}
		}(u)
	}

	wg.Wait()
	close(results)

	var validResults []MirrorResult
	for r := range results {
		if r.Err == nil {
			validResults = append(validResults, r)
		}
	}

	sort.Slice(validResults, func(i, j int) bool {
		return validResults[i].Latency < validResults[j].Latency
	})

	fmt.Printf("\n%sRanked Mirrors by Latency:%s\n", ColorBold, ColorReset)
	for i, r := range validResults {
		fmt.Printf(" %2d. %-55s %s%6.2f ms%s\n", i+1, r.URL, ColorGreen, float64(r.Latency.Microseconds())/1000.0, ColorReset)
	}

	return nil
}
