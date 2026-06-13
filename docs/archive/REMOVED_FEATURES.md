# Removed Features

## Custom Kernel Build Script (`linux-neos-pkgbuild`)

The `linux-neos-pkgbuild` file has been removed from the repository.

**Reason for Removal:**
To simplify the build process and ensure stability for the initial release, we are using the standard Arch Linux kernel (`linux`) or `linux-zen` provided by the repositories instead of building a custom kernel from source. This reduces build complexity and maintenance overhead.

**Future Plans:**
If a custom kernel is required in the future (e.g., for specific hardware support or deep optimization), this file can be retrieved from git history or recreated based on `linux-zen` PKGBUILD.
