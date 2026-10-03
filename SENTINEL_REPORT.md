# Sentinel Security Report

### Risks found
- GPG keys were being fetched from keyserver.ubuntu.com over the unencrypted HKP protocol in build.sh, which is vulnerable to MITM interception and spoofing.

### Fixes applied
- Explicitly defined the hkps:// scheme for all keyserver.ubuntu.com requests in build.sh to enforce TLS encryption for key fetching.

### Remaining attack surface
- None identified regarding keyserver communication.

### Severity summary
- **Severity**: LOW
- **Vulnerability**: Unencrypted Communication Channel (CWE-319)
- **Status**: Fixed
