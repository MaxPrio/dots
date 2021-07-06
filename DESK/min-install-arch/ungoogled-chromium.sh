#!/bin/bash

curl -s 'https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/x86_64/home_ungoogled_chromium_Arch.key' | sudo pacman-key -a -

sudo bash << 'EOFF'
cat >> /etc/pacman.conf << 'EOF'

[home_ungoogled_chromium_Arch]
SigLevel = Required TrustAll
Server = https://download.opensuse.org/repositories/home:/ungoogled_chromium/Arch/$arch
EOF
EOFF

sudo pacman -Sy

sudo pacman -Sy ungoogled-chromium

cat <<"EOF"

To enable adding extentions from chromium web store
  1. On the page 'chrome://flags/#extension-mime-request-handling'
     Change 'Handling of extension MIME type requests' to Always prompt for ins
  2. On the page 'chrome://extensions'
     in the top right, enable Developer mode  
  3. Download 'Chromium.Web.Store.crx'
     from 'github.com/NeverDecaf/chromium-web-store/releases/latest'
  4. Go to the 'file:///path/to/the/Chromium.Web.Store.crx' page, and click 'Add Extention'.

  P.S uBlock Origin page link 'chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm?hl=en'

EOF

