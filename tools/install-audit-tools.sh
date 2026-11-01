#!/bin/bash
# Install repository audit dependencies on an Arch or Ubuntu audit host.
# Run explicitly as root; never intended for the live ISO or installer chroot.
set -euo pipefail
if (( EUID != 0 )); then
    echo 'Run with sudo bash tools/install-audit-tools.sh' >&2
    exit 1
fi
if command -v pacman >/dev/null 2>&1; then
    pacman -Syu --needed --noconfirm git python python-yaml jq shellcheck rust ruby go \
        dotnet-sdk pacman-contrib mktorrent python-pyqt6 qt6-declarative ttf-dejavu
elif command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends git python3 python3-yaml jq shellcheck \
        cargo rustc ruby golang-go dotnet-sdk-8.0 mktorrent python3-pyqt6 \
        python3-pyqt6.qtquick qml6-module-qtquick qml6-module-qtquick-controls \
        qml6-module-qtquick-layouts qml6-module-qtqml-workerscript
    echo 'Ubuntu cannot validate Arch package-repository creation; use Arch for that gate.'
else
    echo 'Unsupported package manager. See CONTRIBUTING.md and the CI dependency list.' >&2
    exit 1
fi
GOBIN=/usr/local/bin go install github.com/rhysd/actionlint/cmd/actionlint@v1.7.12
echo 'Audit dependencies installed. Run python3 tools/audit.py --strict --include-ui.'
