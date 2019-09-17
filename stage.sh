#!/bin/sh
STAGING=staging/priv

mkdir -p "$STAGING/etc/ssh"
[ ! -f "$STAGING/etc/ssh/ssh_host_dsa_key" ] && ssh-keygen -q -N "" -t dsa -f "$STAGING/etc/ssh/ssh_host_dsa_key"
[ ! -f "$STAGING/etc/ssh/ssh_host_ecdsa_key" ] && ssh-keygen -q -N "" -t ecdsa -f "$STAGING/etc/ssh/ssh_host_ecdsa_key"
[ ! -f "$STAGING/etc/ssh/ssh_host_rsa_key" ] && ssh-keygen -q -N "" -t rsa -f "$STAGING/etc/ssh/ssh_host_rsa_key"
[ ! -f "$STAGING/etc/ssh/ssh_host_ed25519_key" ] && ssh-keygen -q -N "" -t ed25519 -f "$STAGING/etc/ssh/ssh_host_ed25519_key"

mkdir -p "$STAGING/etc/wpa_supplicant"
[ ! -z "$WPA_SSID" ] && [ ! -z "$WPA_PSK" ] && cat << EOF > "$STAGING/etc/wpa_supplicant/wpa_supplicant.conf"
# See wpa_supplicant.conf(5) for details

ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=wheel
eapol_version=1
ap_scan=1
fast_reauth=1
update_config=1

$(wpa_passphrase "$WPA_SSID" "$WPA_PSK")
EOF

DEVICE_SUBNET=${DEVICE_SUBNET:-192.168.1}
DEVICE_CIDR=${DEVICE_CIDR:-24}
DEVICE_ID=${DEVICE_ID:-254}
cat <<EOF > "$STAGING/etc/dhcpcd.conf"
# See dhcpcd.conf(5) for details.

# Allow users of this group to interact with dhcpcd via the control socket.
controlgroup wheel
# Inform the DHCP server of our hostname for DDNS.
hostname
# Use the same DUID + IAID as set in DHCPv6 for DHCPv4 ClientID as per RFC4361.
duid
# Persist interface configuration when dhcpcd exits.
persistent
# Rapid commit support.
option rapid_commit
# A list of options to request from the DHCP server.
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
# Respect the network MTU. This is applied to DHCP routes.
option interface_mtu
# A ServerID is required by RFC2131.
require dhcp_server_identifier
# Generate Stable Private IPv6 Addresses based from the DUID
slaac private

# will be ignored if interface doesn't exist
interface wlan0

interface usb0
static ip_address=$DEVICE_SUBNET.$DEVICE_ID/$DEVICE_CIDR
static routers=$DEVICE_SUBNET.1
EOF
