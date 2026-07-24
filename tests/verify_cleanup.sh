#!/bin/bash
# Verify the post-install shellprocess setup.
#
# Netinstall model: the target is a fresh pacstrap, so there is no live-only
# cruft to strip (those drop-ins only ever exist on the live overlay, which is
# never installed to disk). This step instead performs the genuine
# post-bootstrap setup pacstrap doesn't do itself: build locales and initialise
# the pacman keyring so the installed system can verify/update packages.
SHELLPROCESS_CONF="profile/airootfs/etc/calamares/modules/shellprocess.conf"
FAIL=0

echo "Verifying post-install setup in $SHELLPROCESS_CONF..."

# ⚡ Bolt: Load file content once to eliminate repeated fork/exec overhead
CONTENT=$(<"$SHELLPROCESS_CONF")

if [[ "$CONTENT" == *"locale-gen"* ]]; then
    echo "✅ locale-gen present"
else
    echo "❌ locale-gen NOT found"; FAIL=1
fi

if [[ "$CONTENT" == *"pacman-key --init"* ]]; then
    echo "✅ pacman-key --init present"
else
    echo "❌ pacman-key --init NOT found"; FAIL=1
fi

if [[ "$CONTENT" == *"pacman-key --populate archlinux"* ]]; then
    echo "✅ pacman-key --populate archlinux present"
else
    echo "❌ pacman-key --populate archlinux NOT found"; FAIL=1
fi

exit "$FAIL"
