#!/bin/sh

xbps-install -Syu
xbps-install -yu

# fix rng
xbps-query rng-tools || xbps-install -y rng-tools

# logging
# xbps-query socklog-void || xbps-install -y socklog-void

# curl
xbps-query curl || xbps-install -y curl

# zsh
xbps-query zsh || xbps-install -y zsh && [ "$(getent passwd root | cut -d: -f7)" = "/bin/zsh" ] || chsh -s /bin/zsh root

# vim
xbps-query vim || xbps-install -y vim

# development tools
xbps-query gcc || xbps-install -y gcc
xbps-query git || xbps-install -y git
xbps-query make || xbps-install -y make
