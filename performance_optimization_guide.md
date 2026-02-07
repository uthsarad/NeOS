# NeOS Performance Optimization Guide

## Overview
This guide provides specific performance optimization strategies for the NeOS operating system based on the architecture and performance standards defined in the project documentation.

## Key Performance Targets
According to the PERFORMANCE.md document, NeOS aims for:
- Cold Boot Time: < 10s (Hard limit: 15s)
- Login to Desktop: < 3s (Hard limit: 5s)
- Idle RAM Usage: < 800MB (Hard limit: 1.2GB)
- ISO Size: < 2.5GB (Hard limit: 4GB)
- Installation Time: < 5m (Hard limit: 10m)

## Optimization Strategies

### 1. Base System Optimizations

#### Kernel Selection
- Consider using `linux-zen` kernel for better desktop interactive performance as recommended in the documentation
- Ensure proper CPU scheduler configuration for responsiveness

#### I/O Scheduler Configuration
- Configure appropriate I/O schedulers based on storage type:
  - For NVMe/SSD: Use `bfq` or `kyber` scheduler
  - For traditional HDD: Use `mq-deadline`

#### Boot Process Optimization
- Minimize systemd critical chain services
- Identify and disable unnecessary services using `systemd-analyze blame`
- Examples of services to consider disabling:
  ```bash
  sudo systemctl disable lvm2-monitor.service  # If not using LVM
  sudo systemctl disable cups-browsed.service  # If not using printer sharing
  sudo systemctl disable ModemManager.service # If not using modems
  ```

#### Profile Definition Enhancements
Update `/workspace/profiledef.sh` to include performance-focused configurations:

```bash
# Add zram configuration for better memory management
airootfs_file="airootfs.sfs"
airootfs_image_tool_options=("-Xcompression" "zstd")

# Add performance-focused boot parameters
kernel_parameters+=(
  "elevator=kyber"        # I/O scheduler for SSDs
  "nowatchdog"            # Disable watchdog if not needed
  "mce=ignore_ce"         # Ignore corrected errors
  "intel_pstate=enable"   # Intel CPU power management
  "amd_pstate=enable"     # AMD CPU power management
)
```

### 2. Desktop Environment Optimizations (KDE Plasma)

#### Animation Settings
- Set default animation speed to "instant" or "fast" in system settings
- Reduce or eliminate animations that don't enhance user experience

#### File Indexing (Baloo)
- Configure Baloo to exclude build directories and sensitive paths
- Run indexing only on AC power to preserve battery life
- Example configuration in `/etc/baloofilerc`:
```
[Basic Settings]
Indexing-Enabled=false
```

#### Session Management
- Disable "Restore previous session" by default to ensure clean, fast boots
- Configure lightweight session restoration if needed

### 3. Application Layer Optimizations

#### Preloading Frequently Used Applications
- Implement selective preloading for commonly used applications like:
  - Brave browser
  - Dolphin file manager
- Only preload if sufficient RAM is available (> 8GB systems)

#### Background Process Management
- Run `checkupdates` in low-priority background process
- Use `nice` and `ionice` for background tasks to prevent UI blocking
- Example:
```bash
# Low priority update checking
nice -n 19 ionice -c 3 /usr/bin/checkupdates
```

### 4. Package and Repository Optimizations

#### Package Selection
- Review packages in `packages.x86_64`, `packages.i686`, and `packages.aarch64`
- Remove unnecessary packages that increase ISO size and boot time
- Consider replacing heavy alternatives with lighter ones where appropriate

#### Package Compression
- Use efficient compression methods for ISO creation
- The profiledef.sh already specifies erofs, which is good for read-only filesystems

### 5. Hardware-Specific Optimizations

#### Power Management
- Configure appropriate power profiles for different hardware types
- Use TLP for laptop power management
- Enable CPU frequency scaling with performance bias for responsiveness

#### Graphics Drivers
- Ensure proper GPU initialization timing during boot
- Optimize graphics driver loading order to reduce boot time

### 6. Implementation Steps

#### Immediate Actions
1. Review and optimize the packages list in `/workspace/packages.x86_64`
2. Add performance-focused kernel parameters to `profiledef.sh`
3. Implement systemd service optimizations
4. Configure zram for better memory management

#### Configuration Files to Modify
1. Update `/workspace/profiledef.sh` with performance enhancements
2. Add zram configuration at `/etc/systemd/zram-generator.conf`
3. Configure systemd services for optimal boot sequence

#### Testing Commands
To measure performance improvements:
```bash
# Overall boot time
systemd-analyze

# Services slowing down boot
systemd-analyze blame

# Critical chain analysis
systemd-analyze critical-chain

# Memory usage
free -h

# Storage scheduler
cat /sys/block/sda/queue/scheduler
```

### 7. Monitoring and Validation

#### Performance Metrics Tracking
- Implement automated performance testing in CI/CD pipeline
- Track boot times across different hardware configurations
- Monitor RAM usage patterns during idle state

#### Quality Assurance Process
- Include performance benchmarks in the staging validation process
- Test on reference hardware before promoting to stable
- Document performance regression thresholds

## Conclusion

Implementing these optimizations will help NeOS achieve its performance targets while maintaining the stability and user experience goals outlined in the architecture documentation. Focus on measurable improvements that align with the "Speed is a feature" philosophy of the project.
