# Bolt Performance Report: Rust Stream-based Parsing

## What was optimized
The file parsing logic in `parse_package_file()` and `assert_mirrorlists_have_servers()` located in `tools/neos-profile-audit/src/main.rs`. Replaced `fs::read_to_string` with `std::io::BufReader`.

## Before/After Reasoning
### Before
The original implementation used `fs::read_to_string()` to read the entire content of package list files (`packages.x86_64`, etc.) and mirrorlist files into memory as a single large String. It then processed these strings line-by-line using `.lines()`. For potentially large lists (like a mirrorlist with thousands of servers or an extensive package list), this resulted in unnecessary memory allocations and peak RAM usage during the parsing phase. In `assert_mirrorlists_have_servers()`, we only needed to find the *first* active server entry, meaning loading the entire file was particularly wasteful.

### After
- **Stream-based processing:** By using `File::open` paired with `io::BufReader::new(file).lines()`, files are now read incrementally line-by-line. This reduces the application's memory footprint to essentially the size of the longest single line in the file plus a small buffer.
- **Early exit optimization:** In `assert_mirrorlists_have_servers()`, I added a `break` to exit the loop immediately once an active `Server` line is found. Combined with the streaming reader, this means we avoid reading and processing the remainder of the file entirely, significantly reducing I/O and CPU time for long mirrorlists where the active server might be near the top.

## Remaining Performance Risks
The `assert_profiledef_properties()` function currently still uses `fs::read_to_string` because `profiledef.sh` is generally very small (< 2 KB) and loading it into memory once is likely fast enough. Additionally, the `pacman.conf` check within `assert_profiledef_properties` also uses `read_to_string` because it relies on a whole-file `.contains("DatabaseOptional")` check. If these configurations were to grow exceptionally large, converting them to use a `BufReader` could be a beneficial next step.
