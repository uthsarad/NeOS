# Sentinel Security Report

## 1. Risks Found
- **Symlink Attack via `/tmp`**: Temporary progress files (`/tmp/neos-partition-progress`) were being written directly to a world-writable directory without using `mktemp`. An attacker could pre-create this file as a symlink pointing to an arbitrary file, leading to unauthorized overwriting when the script runs as root.
- **Option Injection via `echo -e`**: In multiple error handling and output paths, unsanitized user-controlled variables (like `$SCRIPT_NAME` or `$TARGET_DEV`) were printed using `echo -e`. If these variables started with `-n` or `-e`, they could manipulate `echo`'s behavior, leading to unexpected script execution or information leakage.

## 2. Fixes Applied
- **Fixed Progress File Path**: Changed all instances of `echo "<progress>" > /tmp/neos-partition-progress` to `echo "<progress>" > /run/neos-partition-progress`. The `/run` directory is a safer location for runtime state as it requires elevated privileges to manipulate.
- **Replaced `echo -e` with `printf`**: Replaced all instances of `echo -e` with `printf` and appropriate format strings (e.g., `printf "❌ Error: Target '%s' is not a valid block device.\n" "$TARGET_DEV"`). This mitigates option injection risks by explicitly defining the string format structure.

## 3. Remaining Attack Surface
- The Btrfs volume creation currently relies on dynamically derived device paths. While some sanitization and strict validation is performed (e.g., block device checks), complex device mappings (e.g., logical volumes, encrypted partitions) might still expose edge cases if the paths are manipulated in unexpected ways.

## 4. Severity Summary
- **Symlink Attack via `/tmp`**: **High**. This could lead to a root-level arbitrary file overwrite.
- **Option Injection via `echo -e`**: **Medium**. Primarily a vector for logic manipulation, though limited by strict preceding input validation.
