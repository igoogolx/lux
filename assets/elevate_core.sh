#!/bin/bash
# Lux core elevation bypass - allows lux_core to run as root without
# prompting for password every startup.
# Enables Touch ID for sudo if available.

# Enable Touch ID for sudo if biometrics available
if ! grep -q pam_tid /etc/pam.d/sudo_local 2>/dev/null; then
  if bioutil -r -s 2>/dev/null | grep -q "biometrics_type: 1"; then
    sudo sh -c 'echo "auth       sufficient     pam_tid.so" > /etc/pam.d/sudo_local'
  fi
fi

APP="/Applications/Lux.app"
CORE="$APP/Contents/Frameworks/App.framework/Resources/flutter_assets/assets/bin/lux_core"

[ ! -f "$CORE" ] && CORE=$(find "$APP" -name "lux_core" -type f 2>/dev/null | head -1)
[ -z "$CORE" ] && { osascript -e 'display alert "Lux not found" message "Install Lux first."'; exit 1; }

DIR=$(dirname "$CORE")
REAL="$DIR/lux_core_real"

# Remove quarantine attributes and re-sign
sudo xattr -cr "$APP"
codesign --force --sign - "$CORE" 2>/dev/null

# Replace core binary with a wrapper that runs via sudo
if [ ! -f "$REAL" ]; then
  sudo mv "$CORE" "$REAL"
  printf '#!/bin/bash\nexec sudo "%s/lux_core_real" "$@"\n' "$DIR" | sudo tee "$CORE" >/dev/null
  sudo chmod 755 "$CORE"
fi

# Add NOPASSWD sudoers entry for lux_core
sudo tee /etc/sudoers.d/lux_core >/dev/null <<EOF
$USER ALL=(root) NOPASSWD: $REAL *
EOF
sudo chmod 0440 /etc/sudoers.d/lux_core
sudo visudo -c -f /etc/sudoers.d/lux_core >/dev/null 2>&1 || sudo rm -f /etc/sudoers.d/lux_core

osascript -e 'display notification "Lux elevation fix applied." with title "Done"'
