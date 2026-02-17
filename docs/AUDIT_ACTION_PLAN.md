# NeOS Audit - Quick Action Plan

**Generated:** 2026-02-17  
**Full Report:** See [DEEP_AUDIT.md](./DEEP_AUDIT.md) for complete details

This document provides a prioritized action plan based on the comprehensive audit.

---

## 🚨 Immediate Actions (MUST FIX BEFORE RELEASE)

### 1. Fix Build-Blocking pacman.conf Issue
**Priority:** CRITICAL  
**Time:** 5 minutes  
**Status:** ❌ Currently blocking all builds

**Action:**
```bash
# Edit pacman.conf line 5:
# FROM: SigLevel    = Required DatabaseRequired
# TO:   SigLevel    = Required DatabaseOptional
```

**Verify:**
```bash
bash tests/verify_build_profile.sh  # Should pass
```

**Note:** This ONLY affects build-time. The installed system (`airootfs/etc/pacman.conf`) correctly keeps `DatabaseRequired` for security.

---

## ⚠️ High Priority (Next 1-2 Weeks)

### 2. Add ISO Size Validation to CI
**Priority:** HIGH  
**Time:** 30 minutes  
**Risk:** ISO > 2 GiB cannot be uploaded to GitHub Releases

**Action:** Add to `.github/workflows/build-iso.yml` after "Prepare ISO for upload":

```yaml
- name: Validate ISO Size
  if: github.ref == 'refs/heads/main'
  run: |
    ISO_FILE=$(ls out/*.iso)
    ISO_SIZE=$(stat -c%s "$ISO_FILE")
    MAX_SIZE=$((2 * 1024 * 1024 * 1024))  # 2 GiB
    echo "ISO size: $ISO_SIZE bytes ($(numfmt --to=iec-i --suffix=B $ISO_SIZE))"
    if [ $ISO_SIZE -ge $MAX_SIZE ]; then
      echo "❌ ISO exceeds GitHub release limit!"
      exit 1
    fi
    echo "✅ ISO size is within limits"
```

### 3. Document Architecture Limitations
**Priority:** HIGH  
**Time:** 1 hour  
**Risk:** User confusion about missing features

**Action:** Update README.md and HANDBOOK.md to clarify:
- Calamares installer only available on x86_64
- Snapshot-based updates only on x86_64
- ZRAM compression only on x86_64
- i686 and aarch64 are experimental/community-supported

**Example Addition to README.md:**
```markdown
## Supported Architectures

### x86_64 (Primary)
- ✅ Full feature set (Calamares installer, snapshots, ZRAM)
- ✅ Official support and testing
- ✅ Recommended for production use

### i686 and aarch64 (Experimental)
- ⚠️ Limited feature set (no GUI installer)
- ⚠️ Community-supported
- ⚠️ Use for testing/evaluation only
```

### 4. Add Dependency Validation
**Priority:** HIGH  
**Time:** 30 minutes  
**Risk:** Silent failures if dependencies removed

**Action:** Add to `airootfs/usr/local/bin/neos-autoupdate.sh` after `set -euo pipefail`:

```bash
# Validate dependencies
if ! command -v snapper >/dev/null 2>&1; then
    logger -t neos-autoupdate "ERROR: snapper not installed. Snapshots disabled."
    exit 0
fi

# Check for Btrfs root
if ! findmnt -n -o FSTYPE / | grep -q btrfs; then
    logger -t neos-autoupdate "WARNING: Root is not Btrfs. Snapshots disabled."
    exit 0
fi
```

---

## 📋 Medium Priority (Next Month)

### 5. Fix Documentation URLs
**Time:** 15 minutes  
**Files:** HANDBOOK.md, CONTRIBUTING.md

Find and replace:
- `https://github.com/neos-project/neos` → `https://github.com/uthsarad/NeOS`
- All references to non-existent "NeOS curated repos"

### 6. Add Section Comments to packages.x86_64
**Time:** 10 minutes  

Add structure like i686/aarch64:
```
# Base System
base
linux-lts
...

# Desktop Environment
plasma-meta
sddm
...

# Drivers
nvidia
nvidia-utils
...
```

### 7. Implement Systemd Sandboxing
**Time:** 2 hours  
**Files:** All `.service` files in `airootfs/etc/systemd/system/`

Add to each service:
```ini
[Service]
ProtectSystem=strict
ProtectHome=yes
PrivateTmp=yes
NoNewPrivileges=yes
ProtectKernelTunables=yes
RestrictRealtime=yes
```

Test thoroughly after changes!

### 8. Create ISO Size Test
**Time:** 30 minutes  
**File:** Create `tests/verify_iso_size.sh`

```bash
#!/usr/bin/env bash
set -e

echo "Verifying ISO size optimization settings..."

# Check compression in profiledef.sh
if ! grep -q "xz.*-b.*1M" profiledef.sh; then
    echo "❌ Compression may not achieve target"
    exit 1
fi

# Check NoExtract in pacman.conf
for pattern in "usr/share/man" "usr/share/doc" "usr/share/locale"; do
    if ! grep -q "NoExtract.*$pattern" pacman.conf; then
        echo "❌ Missing NoExtract for $pattern"
        exit 1
    fi
done

echo "✅ ISO size optimization verified"
```

### 9. Improve Error Handling
**Time:** 1 hour  
**Files:** `airootfs/usr/local/bin/neos-liveuser-setup`

Add to all scripts:
```bash
set -euo pipefail

# Error handler
trap 'logger -t "$(basename "$0")" "ERROR at line $LINENO"' ERR
```

### 10. Update CHANGELOG
**Time:** 30 minutes  

Use [Keep a Changelog](https://keepachangelog.com/) format:
```markdown
# Changelog

## [Unreleased]

### Added
- Deep audit report
- Comprehensive testing suite

### Fixed  
- Sudoers NOPASSWD vulnerability (#109)
- Build profile validation

## [0.1.0] - YYYY-MM-DD

### Added
- Initial release
```

---

## 🔄 Long-term Improvements

### 11. Add Pre-Build Testing to CI
**Time:** 1 hour  

Add to `.github/workflows/build-iso.yml`:
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run verification tests
        run: |
          for test in tests/verify_*.sh; do
            [[ "$test" == *"smoketest"* ]] && continue
            echo "Running $test"
            bash "$test"
          done

  build:
    needs: test
    # ... existing build steps
```

### 12. Create Troubleshooting Guide
**Time:** 3 hours  
**File:** Create `docs/TROUBLESHOOTING.md`

Topics to cover:
- Build failures
- Boot issues
- Network problems
- Snapshot rollback
- Driver issues

### 13. Implement Architecture Decision Records
**Time:** 2 hours per decision  
**Location:** Create `docs/decisions/`

Document:
- Why linux-lts over linux-zen
- Why Btrfs + snapper
- Why Calamares installer
- Why plasma-meta
- Why 8 parallel downloads

### 14. Add Security Scanning
**Time:** 2 hours  

Integrate:
- ShellCheck for bash scripts
- CodeQL for security
- Trivy for container/ISO scanning

---

## 📊 Quick Status Dashboard

| Category | Status | Critical Issues | Tests Passing |
|----------|--------|-----------------|---------------|
| Build System | 🔴 | 1 | 7/8 |
| Security | 🟢 | 0 | 3/3 |
| Documentation | 🟡 | 0 | N/A |
| CI/CD | 🟡 | 0 | N/A |
| Testing | 🟢 | 0 | 7/8 |

**Legend:**
- 🔴 Red: Critical issues blocking release
- 🟡 Yellow: Important issues, not blocking
- 🟢 Green: Good state, minor improvements possible

---

## 🎯 Release Readiness Checklist

Before first beta release:

- [ ] **CRITICAL:** Fix pacman.conf DatabaseRequired issue
- [ ] **CRITICAL:** Verify ISO builds successfully
- [ ] **CRITICAL:** Test ISO boots in VM
- [ ] **HIGH:** Add ISO size validation
- [ ] **HIGH:** Document architecture limitations
- [ ] **HIGH:** Fix documentation URLs
- [ ] **MEDIUM:** Update CHANGELOG
- [ ] **MEDIUM:** Add dependency validation
- [ ] **NICE-TO-HAVE:** Pre-build CI tests
- [ ] **NICE-TO-HAVE:** Troubleshooting guide

**Minimum for Release:** First 6 items checked

---

## 📞 Getting Help

If you need assistance with any of these items:

1. **Read the full audit:** [DEEP_AUDIT.md](./DEEP_AUDIT.md)
2. **Check existing issues:** [GitHub Issues](https://github.com/uthsarad/NeOS/issues)
3. **Ask in discussions:** [GitHub Discussions](https://github.com/uthsarad/NeOS/discussions)
4. **Review Arch Wiki:** [Archiso Guide](https://wiki.archlinux.org/title/Archiso)

---

## 📈 Progress Tracking

Update this section as items are completed:

- [x] Deep audit completed (2026-02-17)
- [ ] Critical issue fixed
- [ ] High priority items addressed
- [ ] Medium priority items started
- [ ] Beta release published

**Last Updated:** 2026-02-17  
**Next Review:** After critical fix
