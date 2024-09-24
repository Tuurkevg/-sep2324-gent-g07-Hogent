#! /bin/bash
#
# Provisioning script for srv001

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------

# Enable "Bash strict mode"
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't mask errors in piped commands

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

#------------------------------------------------------------------------------
# Functions
#------------------------------------------------------------------------------

# Predicate that returns exit status 0 if the database root password
# is not set, a nonzero exit status otherwise.
is_mysql_root_password_empty() {
  mysqladmin --user=root status > /dev/null 2>&1
}

#------------------------------------------------------------------------------
# Provision server
#-------------------------------------------------------------------------------

# Laad algemene provisioning-scripts
source "${PROVISIONING_SCRIPTS}/common.sh"

log "=== Starten van server-specifieke provisioning-taken op ${HOSTNAME} ==="
#STATIC IP ---------------------------------------------------------------------------------------------------------
# DHCP uitschakelen voor interface
log "DHCP uitschakelen voor interface $INTERFACE"
sed -i '/^BOOTPROTO=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"


# Controleer of elke waarde ontbreekt en voeg deze toe indien nodig ipv6
if ! grep -q "^IPV6INIT=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then
    echo "IPV6INIT=yes" >> "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
fi

if ! grep -q "^IPV6_AUTOCONF=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then
    echo "IPV6_AUTOCONF=no" >> "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
fi

if ! grep -q "^IPV6_DEFROUTE=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then
    echo "IPV6_DEFROUTE=yes" >> "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
fi

if ! grep -q "^IPV6_FAILURE_FATAL=" "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"; then
    echo "IPV6_FAILURE_FATAL=no" >> "/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
fi

# Stel het statische IP-adres in
log "Statisch IP-adres instellen op $STATIC_IP_DB voor interface $INTERFACE"
sed -i '/^IPADDR=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPADDR=$STATIC_IP_DB" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Regels toevoegen of overschrijven voor NETMASK en GATEWAY
sed -i '/^NETMASK=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "NETMASK=$NETMASK_VLAN42" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
sed -i '/^GATEWAY=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "GATEWAY=$GATEWAY_VLAN42" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE

#dns server toevoegen of overschrijven voor DNS server
log "DNS-server instellen op $DNS_SERVER voor interface $INTERFACE"
sed -i '/^DNS1=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "DNS1=$DNS_SERVER" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
#-------------------------IPV6-----------------------------------------------------------------------------------------
# DNS-server instellen voor IPv6
log "DNS-server instellen op $DNS_SERVER_6 voor interface $INTERFACE"
sed -i '/^DNS2=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "DNS2=$DNS_SERVER_6" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE


# Statisch IPv6-adres instellen
log "Statisch IPv6-adres instellen op $STATIC_IP_DB6 voor interface $INTERFACE"
sed -i '/^IPV6ADDR=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR=$STATIC_IP_DB6" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Prefixlengte instellen voor IPv6
log "Prefixlengte instellen op $PREFIXLEN voor interface $INTERFACE"
sed -i '/^IPV6ADDR_SECONDARIES=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR_SECONDARIES=\"$STATIC_IP_DB6/$PREFIXLEN\"" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Gateway voor IPv6 instellen
log "IPv6 Gateway instellen op $GATEWAY_VLAN42_6 voor interface $INTERFACE"
sed -i '/^IPV6_DEFAULTGW=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6_DEFAULTGW=$GATEWAY_VLAN42_6" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"


#gebruik enkel bridge netwerk voor communicatie door metrci vooran gop 1 te zetten
# Controleer of de route al is toegevoegd
if ! grep -q "default via $GATEWAY_VLAN42 dev $INTERFACE" "/etc/sysconfig/network-scripts/route-eth1"&> /dev/null; then
    # Voeg de route toe aan het routebestand
    echo "default via $GATEWAY_VLAN42 dev $INTERFACE metric 1" | tee -a "/etc/sysconfig/network-scripts/route-eth1" > /dev/null
    log "Route toegevoegd aan /etc/sysconfig/network-scripts/route-eth1"
else
    log "Route bestaat al in /etc/sysconfig/network-scripts/route-eth1"
fi

# Herstart de netwerkservice om de wijzigingen toe te passen
log  "Netwerkservice herstarten"
systemctl restart NetworkManager

log "Netwerkconfiguratie voltooid.  STATTIC IP: $STATIC_IP_DB, NETMASK: $NETMASK_VLAN42, GATEWAY: $GATEWAY_VLAN42, INTERFACE: $INTERFACE. DNS-server instellen op $DNS_SERVER."
#einde netwerk static settings---------------------------------------------------------------------------------------------------------

log "Controleren of MariaDB-server al is geïnstalleerd"
if ! dnf list installed  mysql &> /dev/null; then
    log "MariaDB-server installeren"
    dnf install -y mariadb-server
else
    log "MariaDB-server is al geïnstalleerd"
fi
log "luisteren naar webserver $INTERFACE"
#sed -i "/^#*bind-address/s/^#*bind-address.*/bind-address = $STATIC_IP_DB $STATIC_IP_DB6/" /etc/my.cnf.d/mariadb-server.cnf


log "Controleren of MariaDB-service is ingeschakeld en actief is"
log "starten van httpd service apache"

# Controleer of de httpd service al actief is
if !  systemctl is-active --quiet mariadb; then
     systemctl start mariadb.service
fi

if ! systemctl is-enabled --quiet mariadb; then
    log "MariaDB-service inschakelen en starten"
    systemctl enable --now mariadb.service
else
    log "MariaDB-service is al ingeschakeld en actief"
fi



log "Controleren van firewallregels voor MariaDB"
if ! firewall-cmd --query-rich-rule='rule family="ipv4" source address="'$STATIC_IP_EXTRA'" port port="3306" protocol="tcp" accept' --permanent &> /dev/null; then
    firewall-cmd --add-rich-rule='rule family="ipv4" source address="'$STATIC_IP_WEB'" port port="3306" protocol="tcp" accept' --permanent  
    firewall-cmd --add-rich-rule='rule family="ipv4" source address="'$STATIC_IP_EXTRA'" port port="3306" protocol="tcp" accept' --permanent 
    firewall-cmd --add-rich-rule='rule family="ipv6" source address="'$STATIC_IP_WEB6'" port port="3306" protocol="tcp" accept' --permanent  
    firewall-cmd --add-rich-rule='rule family="ipv6" source address="'$STATIC_IP_EXTRA6'" port port="3306" protocol="tcp" accept' --permanent       
    firewall-cmd --reload
else
    log "Firewallregels voor MariaDB zijn al ingesteld"
fi




log "Securing the database"

if is_mysql_root_password_empty; then
mysql <<_EOF_
  SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${db_root_password}');
  DELETE FROM mysql.user WHERE User=''; 
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
fi

log "Creating and user"

mysql --user=root --password="${db_root_password}" << _EOF_
CREATE DATABASE IF NOT EXISTS ${db_name};
GRANT ALL ON ${db_name}.* TO '${db_user}'@'${STATIC_IP_WEB}' IDENTIFIED BY '${db_password}';
GRANT ALL ON ${db_name}.* TO '${db_user}'@'${STATIC_IP_EXTRA}' IDENTIFIED BY '${db_password}';
GRANT ALL ON ${db_name}.* TO '${db_user}'@'${STATIC_IP_WEB6}' IDENTIFIED BY '${db_password}';
GRANT ALL ON ${db_name}.* TO '${db_user}'@'${STATIC_IP_EXTRA6}' IDENTIFIED BY '${db_password}';
FLUSH PRIVILEGES;
_EOF_

ip link set dev "$INTERFACE" down && ip link set dev "$INTERFACE" up
systemctl restart mariadb
# Herstart de netwerksservice om de wijzigingen door te voeren
log "Provisioning voltooid zonder fouten"