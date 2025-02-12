#!/bin/sh

# Check if the required parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <ifname> <UvAnetID> <password>"
    exit 1
fi

UVANETID="$1"
PASSWORD="$2"
IFNAME="$3"
SSID="eduroam"  # Change to "uva" if needed

# Path to the CA certificate (Adjust this if necessary)
CA_CERT="/etc/ssl/certs/ca-certificates.crt"

# Heavily inspired by https://haluk.github.io/posts-output/2020-10-19-linux/

# Replace <IFNAME> with wifi device name
# Replace <IDENTITY> with student identity (i.e. <USERNAME>@ntnu.no)
# Replace <PASSWORD> with user password
nmcli con add \
  type wifi \
  ifname "$IFNAME" \
  con-name eduroam \
  ssid eduroam \
  ipv4.method auto \
  802-1x.eap peap \
  802-1x.phase2-auth mschapv2 \
  802-1x.identity "$UVANETID@uva.nl" \
  802-1x.password "PASSWORD" \
  wifi-sec.key-mgmt wpa-eap
