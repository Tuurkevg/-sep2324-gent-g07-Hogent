#! /bin/bash
#
# Provisioning script for TFTP-server

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
# Variabelen voor belangrijke gegevens

# Location of provisioning scripts and files
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"
# Variabelen voor belangrijke gegevens
readonly TFTP_DIRECTORY="/etc/tft/sharedfolder"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "=== Starten van server-specifieke provisioning-taken op ${HOSTNAME} ==="

#TFTP installeren en configureren
if ! dnf list installed vsftpd &> /dev/null; then
    log "tftpd-server installeren"
    dnf install -y tftp-server
else
    log "tftpd-server is al geïnstalleerd"
fi

#activeren en enabling tftp server
log "Configuring TFTP server in ${TFTP_DIRECTORY}"
#aanmaken eigen group en user om de specifieke shared folder toe te wijzen aan tfpt service. Safety reasen!
mkdir -p ${TFTP_DIRECTORY}

# Controleer of de groep 'tftp' bestaat en maak deze zo nodig aan
getent group tftp > /dev/null 2>&1 ||  groupadd tftp

# Controleer of de gebruiker 'tftpuser' bestaat en maak deze zo nodig aan
id tftpuser > /dev/null 2>&1 ||  adduser tftpuser

# Voeg de gebruiker 'tftpuser' toe aan de groep 'tftp'
 usermod -aG tftp tftpuser


# configuratie folder instellen 
tee /usr/lib/systemd/system/tftp.service<<EOF
[Unit]
Description=Tftp Server
Requires=tftp.socket
Documentation=man:in.tftpd

[Service]
ExecStart=/usr/sbin/in.tftpd  -c -p -s ${TFTP_DIRECTORY} -v -u tftpuser
StandardInput=socket
Group=tftp
[Install]
WantedBy=multi-user.target
Also=tftp.socket
EOF

# verplaatsen nodige config files voor netwerk configuratie. Dit is de folder waarop je connecteert
cp /vagrant/* ${TFTP_DIRECTORY} -r
rm ${TFTP_DIRECTORY}/provisioning -rf 
rm ${TFTP_DIRECTORY}/provisioning -rf 
# geef alle rechten aan tftp
log "chown -R tftpuser:tftp ${TFTP_DIRECTORY}"
chown -R tftpuser:tftp ${TFTP_DIRECTORY}
chmod -R g+rwx ${TFTP_DIRECTORY}


log "SELinux context instellen voor TFTP"
# Controleer of de SELinux context al is ingesteld
if ! echo $(sudo semanage fcontext --list) | grep -q "${TFTP_DIRECTORY}(/.*)?"; then
    # Als de context nog niet bestaat, voeg het dan toe
    sudo semanage fcontext -a -t public_content_rw_t "${TFTP_DIRECTORY}(/.*)?"
    setsebool -P tftp_anon_write 1
    setsebool -P tftp_home_dir 1
    log "SELinux context toegevoegd."
else
    log "SELinux context bestaat al, geen actie ondernomen."
fi
restorecon -Rv ${TFTP_DIRECTORY}


log "TFTP server geconfigureerd in ${TFTP_DIRECTORY}"
# Controleer of de tftp service al actief is
if !  systemctl is-active --quiet tftp; then
    log "tftp service starten"
     systemctl start tftp
fi
# Controleer of de tftp service al ingeschakeld is om bij opstart te starten
if !  systemctl is-enabled --quiet tftp; then
    log "tftp service activeren"
    systemctl enable  tftp
    log "tftp service is geactiveerd en actief"
fi
#STATIC IP ---------------------------------------------------------------------------------------------------------
# DHCP uitschakelen voor interface
log "DHCP uitschakelen voor interface $INTERFACE"
sed -i '/^BOOTPROTO=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE

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
log "Statisch IP-adres instellen op $STATIC_IP_TFTP voor interface $INTERFACE"
sed -i '/^IPADDR=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "IPADDR=$STATIC_IP_TFTP" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE

# Regels toevoegen of overschrijven voor NETMASK en GATEWAY
 sed -i '/^NETMASK=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "NETMASK=$NETMASK_VLAN1" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
 sed -i '/^GATEWAY=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "GATEWAY=$GATEWAY_VLAN1" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE

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
log "Statisch IPv6-adres instellen op $STATIC_IP_TFTP6 voor interface $INTERFACE"
sed -i '/^IPV6ADDR=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR=$STATIC_IP_TFTP6" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Prefixlengte instellen voor IPv6
log "Prefixlengte instellen op $PREFIXLEN voor interface $INTERFACE"
sed -i '/^IPV6ADDR_SECONDARIES=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR_SECONDARIES=\"$STATIC_IP_TFTP6/$PREFIXLEN\"" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Gateway voor IPv6 instellen
log "IPv6 Gateway instellen op $GATEWAY_VLAN1_6 voor interface $INTERFACE"
sed -i '/^IPV6_DEFAULTGW=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6_DEFAULTGW=$GATEWAY_VLAN1_6" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

#gebruik enkel bridge netwerk voor communicatie door metrci vooran gop 1 te zetten
# Controleer of de route al is toegevoegd
if ! grep -q "default via $GATEWAY_VLAN1 dev $INTERFACE" "/etc/sysconfig/network-scripts/route-eth1"&> /dev/null; then
    # Voeg de route toe aan het routebestand
    echo "default via $GATEWAY_VLAN1 dev $INTERFACE metric 1" | tee -a "/etc/sysconfig/network-scripts/route-eth1" > /dev/null
    log "Route toegevoegd aan /etc/sysconfig/network-scripts/route-eth1"
else
    log "Route bestaat al in /etc/sysconfig/network-scripts/route-eth1"
fi



# Herstart de netwerkservice om de wijzigingen toe te passen
log  "Netwerkservice herstarten"
systemctl restart NetworkManager

log "Netwerkconfiguratie voltooid.  STATTIC IP: $STATIC_IP_TFTP, NETMASK: $NETMASK_VLAN42, GATEWAY: $GATEWAY_VLAN42, INTERFACE: $INTERFACE. DNS-server instellen op $DNS_SERVER."
#einde netwerk static settings---------------------------------------------------------------------------------------------------------
 sleep 5

log "Firewall controleren voor TFTP"
# firewall regels enkel toestaan vanaf vlan1!!! veiligheid risico's beperken!
ip link set dev "$INTERFACE" down && ip link set dev "$INTERFACE" up
if !  firewall-cmd --permanent --zone=public --query-rich-rule 'rule family="ipv4" source address="'${NETWORK_VLAN1}/${NETMASK_VLAN1}'" service name="tftp" accept' &> /dev/null; then
     firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="'${NETWORK_VLAN1}/${NETMASK_VLAN1}'" service name="tftp" accept'
     firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" source address="'${NETWORK_VLAN1_6}/${PREFIXLEN}'" service name="tftp" accept'
     log "Firewallregel voor TFTP toegevoegd"
fi
log "Firewallregels herladen"
firewall-cmd --reload
log "Firewallregels herladen"
systemctl daemon-reload   
systemctl restart tftp