#! /bin/bash
#
# Provisioning script common for all servers

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands
export readonly db_root_password='IcAgWaict9?slamrol'
export readonly db_name='wordpress_db'
export readonly db_user='wordpress_user'
export readonly db_password='Kof3Cup.ByRu'
export readonly VAULTWARDEN_PASSWORD='ArthurVG'
export readonly STATIC_IP_WEB="192.168.107.150"     # 192.168.107.150
export readonly STATIC_IP_DB="192.168.107.149" # 192.168.107.149
export readonly STATIC_IP_EXTRA="192.168.107.151" # 192.168.107.151
export readonly STATIC_IP_RP="192.168.107.164" # 192.168.107.164
export readonly STATIC_IP_TFTP="192.168.107.133" # 192.168.107.133
#--------------------ipv6-------------------------------------------------#
export readonly STATIC_IP_WEB6="2001:db8:ac07:42::6"     # 192.168.107.150
export readonly STATIC_IP_DB6="2001:db8:ac07:42::5" # 192.168.107.149
export readonly STATIC_IP_EXTRA6="2001:db8:ac07:42::7" # 192.168.107.151
export readonly STATIC_IP_RP6="2001:db8:ac07:13::4" # 192.168.107.164
export readonly STATIC_IP_TFTP6="2001:db8:ac07:1::5" # 192.168.107.133
export readonly GATEWAY_VLAN42_6="2001:db8:ac07:42::1" # 192.168.107.145
export readonly GATEWAY_VLAN13_6="2001:db8:ac07:13::1" # 192.168.107.161
export readonly GATEWAY_VLAN1_6="2001:db8:ac07:1::1" # 192.168.107.129
export readonly NETWORK_VLAN1_6="2001:db8:ac07:1::" # 192.168.107.128
export readonly DNS_SERVER_6="2001:db8:ac07:42::4" # 192.168.107.148 windows server
export readonly PREFIXLEN="64" # 64
#-------------------ipv6----------------------------------------------#
export readonly NETMASK_VLAN42="255.255.255.240" # 255.255.255.240
export readonly NETMASK_VLAN13="255.255.255.248" # 255.255.255.248
export readonly NETMASK_VLAN1="255.255.255.240" # 255.255.255.240 
export readonly GATEWAY_VLAN42="192.168.107.145" # 192.168.107.145
export readonly GATEWAY_VLAN13="192.168.107.161" # 192.168.107.161
export readonly GATEWAY_VLAN1="192.168.107.129" # 192.168.107.129
export readonly NETWORK_VLAN1="192.168.107.128" # 192.168.107.128
export readonly INTERFACE="eth1"   # $(ip route get 8.8.8.8 | awk -- '{printf $5}')
export readonly DOMAIN_NAME="g07-blame.internal"
export readonly EXTRA_WEBSERVER="extra.g07-blame.internal"
export readonly DNS_NEXTCLOUD="nextcloud.g07-blame.internal"
export readonly DNS_VAULTWARDEN="vaultwarden.g07-blame.internal"
export readonly DNS_SERVER="192.168.107.148" # 192.168.107.148 windows server

#-----------------------WORDPRES gegevens---------------------------------#

# wordpress configuratie pad
export readonly WP_CONFIG="/var/www/html/wordpress/wp-config.php"
export readonly WP_TITLE="G07blame"
export readonly WP_ADMIN="arthur"
export readonly WP_PASSWORD="arthur"
export readonly WP_EMAIL="arthur@g07blame.internal"
#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
# TODO: put all variable definitions here. Tip: make them readonly if possible.

# Set to 'yes' if debug messages should be printed.
readonly debug_output='yes'

#------------------------------------------------------------------------------
# Helper functions
#------------------------------------------------------------------------------
# Three levels of logging are provided: log (for messages you always want to
# see), debug (for debug output that you only want to see if specified), and
# error (obviously, for error messages).

# Usage: log [ARG]...
#
# Prints all arguments on the standard error stream
log() {
  printf '\e[0;33m[LOG]  %s\e[0m\n' "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard error stream
debug() {
  if [ "${debug_output}" = 'yes' ]; then
    printf '\e[0;36m[DBG] %s\e[0m\n' "${*}"
  fi
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf '\e[0;31m[ERR] %s\e[0m\n' "${*}" 1>&2
}

#------------------------------------------------------------------------------
# Provisioning tasks
#------------------------------------------------------------------------------

log '=== Starting common provisioning tasks ==='

# TODO: insert common provisioning code here, e.g. install EPEL repository, add
# users, enable SELinux, etc.

log "Ensuring SELinux is active"

if [ "$(getenforce)" != 'Enforcing' ]; then
    # Enable SELinux now
    setenforce 1

    # Change the config file
    sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
fi

log "Installing useful packages"

dnf install -y \
    bind-utils \
    cockpit \
    nano \
    tree \
    wget \
    unzip \
    nmap  \
    nc \
    epel-release

log "Enabling essential services"

systemctl enable --now firewalld.service
systemctl enable --now cockpit.socket


# Uitschakelen van root-login via SSH
log "Uitschakelen van root-login via SSH en alleen toestaan van SSH-keyauthenticatie"
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Toestaan van alleen SSH-keyauthenticatie
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Toevoegen van publieke sleutel voor SSH-toegang van Laptop Arthur Van Ginderachter
if ! grep -q "arthur" /home/vagrant/.ssh/authorized_keys; then
log "toevoegen van ssh pub key van Arthur Van Ginderachter"
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCUEs7VPgfQvwOEZfLkOQpK/5oX1PFdxzeeDisjCsnWnYhCWAjuXi+BBkNW045IJ5MpGdFSkC7VlC3pFXg+vIJCiBOyugT+TpFjGoCxAxlut/yUs8f9jvsRymrNo7YuE4+++AtJg2dmRyEQ7g+GWm/LO0usXlMLcKzUNPj9oVPEEatNVVh1VatgyBCXL51S2B7gpXAoeiItZppz1nj2DPZi/WRGNUjWbsVbLu6e5UwWxCmXkEk/VbAL59HrPY93uX08Nm8uNaubnCPKcsezuwch+oi34w8yf7yFyLfuBBbOBsQZ0tAsOwOLVjlVd5pm9ZYXVQ27yKyfiqCVPsaRNoTmdcTLYPRXNphEtP0R37nty0ZHARvVChNzvJ1Kxr0XsfejkuKp0yGHgKldDpZd6aDQBK+gpifgqCtWb7G9L4q+oLS8ACoOGpiirc0fV5Xd9lzTIwl7yYeTxAF/6P3RqAnqVYxOupTpyqdLqZb1lLbCFFrKC6q6WWwPudgd6Oj3T2U= arthur@DarkArthLap" >> /home/vagrant/.ssh/authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT+RP+oeRFuTpBHOb29WHzzHgA2XgZQrUgldR7K7Hc0GwoqyB3+5C4mfMDTOBfLJSW3X3GAQ8lTpY15s+5ltVenQt4UvMkY2sObMRkSkpK05S2QUtGr/Puo/1G2cuArYKntZDt+Oay5/3SsYy6h7cpcsMTHfmfgEdgFIaHrkAP40FnUJ/2MYAB2iePVvMH9EwUrsA3W1xn89dNqHtqLRyrdbHFzMdx5Dh41VDh0lGFCIeBRlIDCmFrC2qa1alieWC4PkhukIkWFLXTmcqoUj9/8HNIkW2ZWXi/fb7e4HSBECnPakXuMBB3iB9u0yDLvl0o/IUbtsB2fRY2RqMN6kbT g07-blame\administrator@DC-SEP-2324" >> /home/vagrant/.ssh/authorized_keys
fi

# toevoegen eigen oub en private key
if [ ! -f /home/vagrant/.ssh/sep.pub ]; then
    log "toevoegen van eigen ssh key"
    cp /vagrant/sep.pub /home/vagrant/.ssh/sep.pub
    cp /vagrant/sep /home/vagrant/.ssh/sep
    chown vagrant:vagrant /home/vagrant/.ssh/sep
    chown vagrant:vagrant /home/vagrant/.ssh/sep.pub
    chmod 600 /home/vagrant/.ssh/sep
    chmod 644 /home/vagrant/.ssh/sep.pub
fi


# Herstart SSH-service om wijzigingen toe te passen
systemctl restart sshd
