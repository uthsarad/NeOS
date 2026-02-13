## Prerequisites for Building NeOS ISO

Before building the NeOS ISO, ensure your environment meets the following requirements. NeOS uses a custom Archiso profile that depends on specific tools and repositories (notably Chaotic-AUR and EROFS support).

### 1. Host Operating System
*   **Recommended:** Arch Linux or an Arch-based distribution (EndeavourOS, Manjaro, etc.).
*   **Alternative:** Other Linux distributions (Ubuntu, Fedora, etc.) via containerization.
    *   *Note:* You can build inside a Docker/Podman container using the `archlinux:base-devel` image, but you must enable privileged mode (`--privileged`) to allow mounting loop devices.

### 2. Hardware Requirements
Building a modern desktop ISO is resource-intensive.
*   **RAM:** Minimum **8GB**. (16GB+ recommended for faster compression).
*   **Disk Space:** **40GB - 60GB** of free space.
    *   The build process downloads hundreds of packages and creates a large work directory (`work/`).
    *   The final ISO will be approx. 3-4GB.
*   **CPU:** Multi-core processor recommended.

### 3. Software Dependencies
The build process relies on standard Archiso tools plus NeOS-specific requirements.

*   **Build Tools:** `archiso`, `git`, `base-devel`
*   **Filesystem Tools:** `erofs-utils` (CRITICAL: NeOS uses EROFS for the root filesystem), `squashfs-tools`, `dosfstools`, `mtools`, `libisoburn`, `btrfs-progs`.
*   **Bootloader Support:** `grub`.
*   **Optional but Recommended:**
    *   `qemu-desktop`: For testing the ISO immediately after building.
    *   `reflector`: For updating mirrorlists to speed up package downloads.

#### Install All Dependencies
Run this single command to install everything needed:

```bash
sudo pacman -S --needed archiso git base-devel erofs-utils dosfstools mtools libisoburn squashfs-tools grub btrfs-progs qemu-desktop reflector
```

### 4. Configure Chaotic-AUR (Required)
NeOS pulls optimized kernels (e.g., `linux-lqx`) and other pre-built packages from the **Chaotic-AUR** repository. You **must** configure this on your host machine because `mkarchiso` uses your host's pacman configuration to resolve dependencies.

1.  **Receive and Sign the Key:**
    ```bash
    sudo pacman-key --recv-key 3056513887B78AEB
    sudo pacman-key --lsign-key 3056513887B78AEB
    ```

2.  **Install the Keyring and Mirrorlist:**
    ```bash
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    ```

3.  **Add to `/etc/pacman.conf`:**
    Edit your configuration file (`sudo nano /etc/pacman.conf`) and append the following at the end:
    ```ini
    [chaotic-aur]
    Include = /etc/pacman.d/chaotic-mirrorlist
    ```
    *Note: Place this above the `[multilib]` section if you have it enabled, or at the bottom.*

4.  **Update Databases:**
    ```bash
    sudo pacman -Sy
    ```

### 5. Sudo / Root Privileges
*   The build script (`build.sh`) and `mkarchiso` require **root privileges** to mount filesystems and create device nodes.
*   Ensure your user is in the `wheel` group or has `sudo` access.

### Troubleshooting Prerequisites
*   **"erofs-utils not found" / "mkfs.erofs failed":** Ensure you installed `erofs-utils`. NeOS uses EROFS instead of SquashFS for better performance.
*   **"Target not found: linux-lqx":** You skipped the Chaotic-AUR setup. The build cannot find the kernel package without this repo.
*   **"No space left on device":** The `work/` directory can grow large. Run `sudo rm -rf work/` to clean up failed builds, or resize your partition.
*   **Slow Downloads:** Update your mirrorlist using reflector: `sudo reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist`.

---

### Ready to Build?
Once prerequisites are met, you can clone the repo and start the build:

```bash
git clone https://github.com/neos-project/neos.git
cd neos
sudo ./build.sh
```
