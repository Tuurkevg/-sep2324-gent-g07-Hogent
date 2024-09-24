#! /bin/bash
#
# Provisioning script for webserver

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
# Locatie van het WordPress-configuratiebestand
# Pad naar de Apache-configuratiebestanden
readonly APACHE_CONF_DIR="/etc/httpd/conf.d"
readonly APACHE_LOG_DIR="/var/log/httpd"

#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "=== Starten van server-specifieke provisioning-taken op ${HOSTNAME} ==="
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
log "Statisch IP-adres instellen op $STATIC_IP_WEB voor interface $INTERFACE"
sed -i '/^IPADDR=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "IPADDR=$STATIC_IP_WEB" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE

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
log "Statisch IPv6-adres instellen op $STATIC_IP_WEB6 voor interface $INTERFACE"
sed -i '/^IPV6ADDR=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR=$STATIC_IP_WEB6" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Prefixlengte instellen voor IPv6
log "Prefixlengte instellen op $PREFIXLEN voor interface $INTERFACE"
sed -i '/^IPV6ADDR_SECONDARIES=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR_SECONDARIES=\"$STATIC_IP_WEB6/$PREFIXLEN\"" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Gateway voor IPv6 instellen
log "IPv6 Gateway instellen op $GATEWAY_VLAN42_6 voor interface $INTERFACE"
sed -i '/^IPV6_DEFAULTGW=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6_DEFAULTGW=$GATEWAY_VLAN42_6" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"


#gebruik enkel bridge netwerk voor communicatie door metrci vooran gop 1 te zetten
# Controleer of de route al is toegevoegd
if ! grep -q "default via $GATEWAY_VLAN42 dev $INTERFACE" "/etc/sysconfig/network-scripts/route-eth1"; then
    # Voeg de route toe aan het routebestand
    echo "default via $GATEWAY_VLAN42 dev $INTERFACE metric 1" | tee -a "/etc/sysconfig/network-scripts/route-eth1" > /dev/null
    log "Route toegevoegd aan /etc/sysconfig/network-scripts/route-eth1"
else
    log "Route bestaat al in /etc/sysconfig/network-scripts/route-eth1"
fi

# Herstart de netwerkservice om de wijzigingen toe te passen
log  "Netwerkservice herstarten"
systemctl restart NetworkManager

log "Netwerkconfiguratie voltooid.  STATTIC IP: $STATIC_IP_WEB, NETMASK: $NETMASK_VLAN42, GATEWAY: $GATEWAY_VLAN42, INTERFACE: $INTERFACE. DNS-server instellen op $DNS_SERVER."
#einde netwerk static settings---------------------------------------------------------------------------------------------------------

# Controleer of de pakketten geïnstalleerd zijn en installeer indien nodig

if ! dnf list installed httpd php php-curl php-bcmath php-gd php-soap php-zip php-curl php-mbstring php-mysqlnd php-gd php-xml php-intl php-zip &> /dev/null; then
    log "installeren van alle benodigde software voor de webserver"
     dnf install -y httpd php php-curl php-bcmath php-gd php-soap php-zip php-curl php-mbstring php-mysqlnd php-gd php-xml php-intl php-zip
fi
ip link set dev $INTERFACE down &&  ip link set dev $INTERFACE up


# firewall openzetten voor http en https TESTEN AUB
log "firewall regels voor connectie enkel van Reverse Proxy:${STATIC_IP_RP} voor http"
if ! firewall-cmd --query-rich-rule='rule family="ipv4" source address="'$STATIC_IP_RP'" port port="80" protocol="tcp" accept' --permanent &> /dev/null; then
    firewall-cmd --add-rich-rule='rule family="ipv4" source address="'$STATIC_IP_RP'" port port="80" protocol="tcp" accept' --permanent  
    firewall-cmd --add-rich-rule='rule family="ipv6" source address="'$STATIC_IP_RP6'" port port="80" protocol="tcp" accept' --permanent  
    firewall-cmd --reload
else
    log "Firewallregels voor webserver zijn al ingesteld"
fi

# Log het starten van de apache service
log "starten van httpd service apache"

# Controleer of de httpd service al actief is
if !  systemctl is-active --quiet httpd; then
     systemctl start httpd
fi
# Controleer of de httpd service al ingeschakeld is om bij opstart te starten
if !  systemctl is-enabled --quiet httpd; then
     systemctl enable httpd
fi
log "httpd service is geactiveerd en actief" 


log "de configuratie van SELinux"

# Controleer de huidige staat van de httpd_can_network_connect_db boolean
if !  getsebool httpd_can_network_connect_db | grep -q -- 'httpd_can_network_connect_db --> on'; then
    log "SELINUx anapassen voor apache connectie met database"
     setsebool -P httpd_can_network_connect_db on
fi

# Controleer de huidige staat van de httpd_can_network_connect boolean
if !  getsebool httpd_can_network_connect | grep -q -- 'httpd_can_network_connect --> on'; then
     setsebool -P httpd_can_network_connect on
fi


log "installatie van WORDPRESS"
# Controleer of WordPress nog niet is geïnstalleerd
if [ ! -d "/var/www/html/wordpress" ]; then
    # Download en installeer WordPress
     wget -P /var/www/html/ https://wordpress.org/latest.zip
     unzip /var/www/html/latest.zip -d /var/www/html/
     rm /var/www/html/latest.zip  # Verwijder het zip-bestand na extractie

    # Geef de juiste eigendom aan Apache (httpd) gebruiker
     chown -R apache:apache /var/www/html/wordpress/

    # Zet SELinux-beveiligingscontext indien niet toegepast
     chcon -R -t httpd_sys_rw_content_t /var/www/html/wordpress &> /dev/null

else
    log "WordPress is al geïnstalleerd."
fi
# Apache configuratie wordpress
log "configuratie wordpress"
VHOST_CONF="${APACHE_CONF_DIR}/wordpress.conf"
VHOST_CONTENT=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@${DOMAIN_NAME}
    ServerName ${DOMAIN_NAME}
    ServerAlias www.${DOMAIN_NAME}
    DocumentRoot /var/www/html/wordpress

    <Directory /var/www/html/wordpress/>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/${DOMAIN_NAME}_error.log
    CustomLog ${APACHE_LOG_DIR}/${DOMAIN_NAME}_access.log combined
</VirtualHost>
EOF
)

# Schrijf de VirtualHost-configuratie naar het bestand
echo "${VHOST_CONTENT}" |  tee "${VHOST_CONF}"
#--------------------------------------------------------------------------------
#volledige config van wordpress --> skip manual installation

# WordPress-configuratie inhoud met omgevingsvariabelen
WP_CONFIG_CONTENT=$(cat <<'EOF'
<?php
define( 'DB_NAME', '${db_name}' );
define( 'DB_USER', '${db_user}' );
define( 'DB_PASSWORD', '${db_password}' );
define( 'DB_HOST', '${STATIC_IP_DB}' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
# Controleer of de array-sleutel bestaat voordat je deze gebruikt http_forwarder
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') {
    $_SERVER['HTTPS'] = 'on';
}
#controleer of de array sleutel bestaat voordat je deze gebruikt httpost
if (isset($_SERVER['HTTP_HOST'])) {
    $http_host = $_SERVER['HTTP_HOST'];
} else {
    // Set a default value or handle the case when HTTP_HOST is not set
    $http_host = 'your_default_host';
}
require_once ABSPATH . 'wp-settings.php';
EOF
)

# Vervang omgevingsvariabelen in de WordPress-configuratie
WP_CONFIG_CONTENT=$(echo "${WP_CONFIG_CONTENT}" | \
    sed "s/'\${db_name}'/'${db_name}'/g" | \
    sed "s/'\${db_user}'/'${db_user}'/g" | \
    sed "s/'\${db_password}'/'${db_password}'/g" | \
    sed "s/'\${STATIC_IP_DB}'/'${STATIC_IP_DB}'/g")

# Schrijf de WordPress configuratie naar het configuratiebestand
echo "${WP_CONFIG_CONTENT}" |  tee "${WP_CONFIG}" >/dev/null



# Download WP-CLI lokaal als het nog niet bestaat
if [ ! -f "/usr/local/bin/wp/wp-cli.phar" ]; then
    mkdir -p /usr/local/bin/wp/
    log "Downloaden van WP-CLI voor configuratie van WordPress account"
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp/wp-cli.phar
    chmod +x  /usr/local/bin/wp/wp-cli.phar
fi
# Verander eigendom van de uploads map naar de webserver gebruiker
chown -R apache:apache /var/www/html/wordpress/wp-content/*
# Stel de juiste permissies in voor de uploads map
chmod -R 755 /var/www/html/wordpress/wp-content/*
cd /usr/local/bin/wp/
# Controleer of WordPress al geïnstalleerd is voordat je doorgaat
if ! $(/usr/local/bin/wp/wp-cli.phar core is-installed --path=/var/www/html/wordpress ); then
    # Voer de WP core installatie uit
    log "WordPress core installatie"
    #echo "/usr/local/bin/wp/wp-cli.phar core install --path="/var/www/html/wordpress/" --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="${WP_PASSWORD}" --admin_email="${WP_EMAIL}""
    /usr/local/bin/wp/wp-cli.phar core install --path="/var/www/html/wordpress/" --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="${WP_PASSWORD}" --admin_email="${WP_EMAIL}" --quiet --skip-email
fi

# Controleer of de huidige site-URL overeenkomt met de gewenste URL
if [ "$(/usr/local/bin/wp/wp-cli.phar option get siteurl --path="/var/www/html/wordpress/")" != "https://${DOMAIN_NAME}" ]; then
    # Als de huidige URL niet overeenkomt, voer dan de WP-CLI-opdrachten uit om de site-URL's bij te werken
    /usr/local/bin/wp/wp-cli.phar option update siteurl "https://${DOMAIN_NAME}" --path="/var/www/html/wordpress/"
    /usr/local/bin/wp/wp-cli.phar option update home "https://${DOMAIN_NAME}" --path="/var/www/html/wordpress/"
    
fi

# Apache configuratie extra website
log "configuratie 2DE webserver (EXTRA) -------------------"
VHOST_CONF="${APACHE_CONF_DIR}/extra.conf"
VHOST_CONTENT=$(cat <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@${EXTRA_WEBSERVER}
    ServerName ${EXTRA_WEBSERVER}
    ServerAlias www.${EXTRA_WEBSERVER}
    DocumentRoot /var/www/html/extra

    <Directory /var/www/html/extra/>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/${EXTRA_WEBSERVER}_error.log
    CustomLog ${APACHE_LOG_DIR}/${EXTRA_WEBSERVER}_access.log combined
</VirtualHost>
EOF
)
log "website bestanden verplaatsen naar /extra folder"
mkdir -p /var/www/html/extra
cp -rf /vagrant/extra/* /var/www/html/extra/ 2>/dev/null
# Geef de juiste eigendom aan Apache (httpd) gebruiker
    chown -R apache:apache /var/www/html/extra/
# Zet SELinux-beveiligingscontext indien niet toegepast
    chcon -R -t httpd_sys_rw_content_t /var/www/html/extra &> /dev/null
# Schrijf de VirtualHost-configuratie naar het bestand
echo "${VHOST_CONTENT}" |  tee "${VHOST_CONF}"


log "signature naar off en tokens naar prod --> veiligheid NMAP en sniffing"
# Controleer of versi evan apache getoont wordt bij sniffen NMAP --> veiligheid
if ! grep -q "ServerTokens Prod" /etc/httpd/conf/httpd.conf; then
    sed -i '/^#ServerTokens /s/^#//' /etc/httpd/conf/httpd.conf
    sed -i '/^ServerTokens /s/^/#/' /etc/httpd/conf/httpd.conf
    echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf
fi
# Controleer of versie getoont wordt bij error of page not found, om deze te verbergem
if ! grep -q "ServerSignature Off" /etc/httpd/conf/httpd.conf; then
    sed -i '/^#ServerSignature /s/^#//' /etc/httpd/conf/httpd.conf
    sed -i '/^ServerSignature /s/^/#/' /etc/httpd/conf/httpd.conf
    echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf
fi



# Herstart de Apache-webserver
systemctl restart httpd
log "Provisioning voltooid zonder fouten"