#!/bin/sh

set -uex

incus launch images:debian/13 alexveecle --vm -c limits.cpu=4 -c limits.memory=8GiB -d root,size=50GiB

until incus exec alexveecle -- uptime ; do
    echo not ready yet
    sleep 5
done

incus exec alexveecle -- sh -c 'cat >/script' <<EOF
set -uex

adduser -q --disabled-password alex --comment ""

chpasswd <<INNER
alex:alex
INNER

adduser alex sudo

apt update
apt full-upgrade -y
apt install -y tasksel

debconf-set-selections <<INNER
keyboard-configuration  keyboard-configuration/altgr    select  The default for the keyboard layout
keyboard-configuration  keyboard-configuration/compose  select  No compose key
keyboard-configuration  keyboard-configuration/ctrl_alt_bksp    boolean false
# Country of origin for the keyboard:
keyboard-configuration  keyboard-configuration/layout   select  Spanish
keyboard-configuration  keyboard-configuration/layoutcode       string  es
keyboard-configuration  keyboard-configuration/model    select  Generic 105-key PC
keyboard-configuration  keyboard-configuration/modelcode        string  pc105
keyboard-configuration  keyboard-configuration/optionscode      string
keyboard-configuration  keyboard-configuration/store_defaults_in_debconf_db     boolean true
keyboard-configuration  keyboard-configuration/switch   select  No temporary switch
keyboard-configuration  keyboard-configuration/toggle   select  No toggling
# Keep the current keyboard layout in the configuration file?
keyboard-configuration  keyboard-configuration/unsupported_config_layout        boolean true
# Keep current keyboard options in the configuration file?
keyboard-configuration  keyboard-configuration/unsupported_config_options       boolean true
# Keep default keyboard layout ()?
keyboard-configuration  keyboard-configuration/unsupported_layout       boolean true
# Keep default keyboard options ()?
keyboard-configuration  keyboard-configuration/unsupported_options      boolean true
keyboard-configuration  keyboard-configuration/variant  select  Spanish
keyboard-configuration  keyboard-configuration/variantcode      string
keyboard-configuration  keyboard-configuration/xkb-keymap       select  us
INNER

apt-get -q -y -o APT::Install-Recommends=true -o APT::Get::AutomaticRemove=true -o Acquire::Retries=3 install task-desktop

systemctl start gdm

EOF

incus exec alexveecle -- bash /script
