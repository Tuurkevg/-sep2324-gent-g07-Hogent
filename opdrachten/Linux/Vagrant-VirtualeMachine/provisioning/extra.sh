#! /bin/bash
#
# Provisioning script for extra website / nextcloud server

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
export readonly APACHE_CONF_DIR="/etc/httpd/conf.d"
export readonly APACHE_LOG_DIR="/var/log/httpd"
export readonly nextcloudRootuser="Arthur"
export readonly nextcloudRootpassword="plopkoek123"
export readonly nextclouduser="troller"
export readonly OC_PASS="gekuntdepotopmetwindows" #wachtwoord van user nextcloud

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
log "Statisch IP-adres instellen op $STATIC_IP_EXTRA voor interface $INTERFACE"
sed -i '/^IPADDR=/d' /etc/sysconfig/network-scripts/ifcfg-$INTERFACE
echo "IPADDR=$STATIC_IP_EXTRA" >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE

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
log "Statisch IPv6-adres instellen op $STATIC_IP_EXTRA6 voor interface $INTERFACE"
sed -i '/^IPV6ADDR=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR=$STATIC_IP_EXTRA6" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

# Prefixlengte instellen voor IPv6
log "Prefixlengte instellen op $PREFIXLEN voor interface $INTERFACE"
sed -i '/^IPV6ADDR_SECONDARIES=/d' /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"
echo "IPV6ADDR_SECONDARIES=\"$STATIC_IP_EXTRA6/$PREFIXLEN\"" >> /etc/sysconfig/network-scripts/ifcfg-"$INTERFACE"

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

log "Netwerkconfiguratie voltooid.  STATTIC IP: $STATIC_IP_EXTRA, NETMASK: $NETMASK_VLAN42, GATEWAY: $GATEWAY_VLAN42, INTERFACE: $INTERFACE. DNS-server instellen op $DNS_SERVER."
#einde netwerk static settings---------------------------------------------------------------------------------------------------------
log "----------------installatie backup extra website--------------------------------------"
# Controleer of de pakketten geïnstalleerd zijn en installeer indien nodig

if ! dnf list installed httpd php php-curl php-bcmath php-gd php-soap php-zip php-curl php-mbstring php-mysqlnd php-gd php-xml php-intl php-zip &> /dev/null; then
    log "installeren van alle benodigde software voor de webserver"
     dnf install -y httpd php php-curl php-bcmath php-gd php-soap php-zip php-curl php-mbstring php-mysqlnd php-gd php-xml php-intl php-zip
fi
ip link set dev $INTERFACE down &&  ip link set dev $INTERFACE up
log "php ram van 128m naar 1000M"
sed -i 's/^memory_limit = .*/memory_limit = 1000M/' /etc/php.ini

# firewall openzetten voor http
log "firewall regels voor connectie enkel van Reverse Proxy:${STATIC_IP_RP} voor http"
if ! firewall-cmd --query-rich-rule='rule family="ipv4" source address="'$STATIC_IP_RP'" port port="80" protocol="tcp" accept' --permanent &> /dev/null; then
    firewall-cmd --add-rich-rule='rule family="ipv4" source address="'$STATIC_IP_RP'" port port="80" protocol="tcp" accept' --permanent  
    firewall-cmd --add-rich-rule='rule family="ipv4" source address="'$STATIC_IP_RP'" port port="8000" protocol="tcp" accept' --permanent  
    firewall-cmd --add-rich-rule='rule family="ipv6" source address="'$STATIC_IP_RP6'" port port="80" protocol="tcp" accept' --permanent  
    firewall-cmd --add-rich-rule='rule family="ipv6" source address="'$STATIC_IP_RP6'" port port="8000" protocol="tcp" accept' --permanent  
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
log "-----------------------------------------------INSTALLATIE BACKUP WORDPRES-------------------------"


log "installatie van WORDPRESS"
# Controleer of WordPress nog niet is geïnstalleerd
if [ ! -d "/var/www/html/wordpress" ]; then
    # Download en installeer WordPress
     wget -P /var/www/html/ https://wordpress.org/latest.zip
     unzip /var/www/html/latest.zip -d /var/www/html/
     rm /var/www/html/latest.zip -rf # Verwijder het zip-bestand na extractie

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
if ! $(/usr/local/bin/wp/wp-cli.phar core is-installed --path=/var/www/html/wordpress --allow-root ); then
    # Voer de WP core installatie uit
    log "----------------WordPress core installatie----------------------------"
    #echo "/usr/local/bin/wp/wp-cli.phar core install --path="/var/www/html/wordpress/" --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="${WP_PASSWORD}" --admin_email="${WP_EMAIL}""
    /usr/local/bin/wp/wp-cli.phar core install --path="/var/www/html/wordpress/" --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_ADMIN}" --admin_password="${WP_PASSWORD}" --admin_email="${WP_EMAIL}" --quiet --skip-email --allow-root
fi

# Controleer of de huidige site-URL overeenkomt met de gewenste URL
if [ "$(/usr/local/bin/wp/wp-cli.phar option get siteurl --allow-root --path="/var/www/html/wordpress/")" != "https://${DOMAIN_NAME}" ]; then
    # Als de huidige URL niet overeenkomt, voer dan de WP-CLI-opdrachten uit om de site-URL's bij te werken
    /usr/local/bin/wp/wp-cli.phar option update siteurl "https://${DOMAIN_NAME}" --path="/var/www/html/wordpress/" --allow-root
    /usr/local/bin/wp/wp-cli.phar option update home "https://${DOMAIN_NAME}" --path="/var/www/html/wordpress/" --allow-root
    
fi

log "---------------------------------INSTALLATIE VAULTWARDEN-----------------------------------"
log "controleren en aanmaken van user 'vaultwarden'"
id vaultwarden > /dev/null 2>&1 ||  adduser vaultwarden
log "controleren of vaultwarden al geinstalleerd is"
if [ ! -d "/opt/vaultwarden" ]; then
    log "vaultwarden nog niet geinstalleeerd": Installeren...
    mkdir vw-image

    wget -P vw-image https://raw.githubusercontent.com/jjlin/docker-image-extract/main/docker-image-extract
    bash vw-image/docker-image-extract vaultwarden/server:alpine

    mkdir -p /opt/vaultwarden /var/lib/vaultwarden/data
    chown -R vaultwarden:vaultwarden /var/lib/vaultwarden

    mv output/vaultwarden /opt/vaultwarden
    mv output/web-vault /var/lib/vaultwarden

    rm -Rf output -rf
    rm -Rf docker-image-extract -rf
    rm -Rf vw-image -rf
    log "vaultwarden is succesvol geinstalleerd!"
fi


# Maak een .env-bestand voor Vaultwarden
log ".env-bestand voor Vaultwarden maken/aanpassen"
tee /var/lib/vaultwarden/.env > /dev/null <<EOF
DOMAIN=https://${DNS_VAULTWARDEN}
ADMIN_TOKEN=${VAULTWARDEN_PASSWORD}
HIBP_API_KEY=${VAULTWARDEN_PASSWORD}
ORG_CREATION_USERS=user@example.com
SIGNUPS_ALLOWED=true
SMTP_HOST=smtp.example.com
SMTP_FROM=vaultwarden@example.com
SMTP_FROM_NAME=Vaultwarden
SMTP_PORT=587         
SMTP_SSL=true         
SMTP_EXPLICIT_TLS=false 
SMTP_USERNAME=user@example.com
SMTP_PASSWORD=mysmtppassword
SMTP_TIMEOUT=15
ROCKET_ADDRESS=${STATIC_IP_EXTRA}
DATABASE_URL=mysql://${db_user}:${db_password}@${STATIC_IP_DB}:3306/${db_name}
LOG_FILE=/var/lib/vaultwarden/logs
EOF



# Maak systemd-servicebestand voor Vaultwarden
log "systemd-servicebestand voor Vaultwarden maken/ aanpassen"
tee /etc/systemd/system/vaultwarden.service > /dev/null <<EOF
[Unit]
Description=Bitwarden Server (Rust Edition)
Documentation=https://github.com/dani-garcia/vaultwarden
After=network.target

[Service]
User=vaultwarden
Group=vaultwarden
EnvironmentFile=/var/lib/vaultwarden/.env
ExecStart=/opt/vaultwarden/vaultwarden
LimitNOFILE=1048576
LimitNPROC=64
PrivateTmp=true
PrivateDevices=true
ProtectHome=true
ProtectSystem=strict
WorkingDirectory=/var/lib/vaultwarden
ReadWriteDirectories=/var/lib/vaultwarden
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target

EOF
restorecon -RFv /opt/vaultwarden/vaultwarden
# SELinux-configuratie
if command -v semanage >/dev/null 2>&1; then
    setsebool -P httpd_can_network_connect on
    log "SELinux-configuratie voor Vaultwarden toegevoegd"
fi

# Log het starten van de apache service
log "starten van vaultwarden service "

# Controleer of de vaultwarden service al actief is
if !  systemctl is-active --quiet vaultwarden; then
    systemctl start vaultwarden
fi
# Controleer of de httpd service al ingeschakeld is om bij opstart te starten
if !  systemctl is-enabled --quiet vaultwarden; then
     systemctl enable vaultwarden
fi

log "--------------------------------- Installatie Nextcloud-server ---------------------------------"
# Controleer of de pakketten geïnstalleerd zijn en installeer indien nodig
# if ! dnf list installed bash-completion httpd mariadb mariadb-server mlocate php php-bcmath php-cli php-curl php-gd php-json php-imagick php-mbstring php-mysqlnd php-opcache php-pecl-apcu php-process php-soap php-xml php-intl php-zip &> /dev/null; then
    log "installeren van alle benodigde software voor de Nextcloud- en webserver"
     dnf install -y bash-completion httpd mlocate php php-bcmath php-cli php-curl php-gd php-json php-imagick php-mbstring php-mysqlnd php-opcache php-pecl-apcu php-process php-soap php-xml php-intl php-zip --skip-broken
# fi

# Controleer of Nextcloud al is geïnstalleerd op de opgegeven locatie
if [ ! -d "/var/www/html/nextcloud" ]; then
    # Download Nextcloud als het nog niet is geïnstalleerd
    echo "Nextcloud is nog niet geïnstalleerd. Downloaden..."
    wget https://download.nextcloud.com/server/releases/latest.zip
    unzip latest.zip -d /var/www/html/
    mkdir /var/www/html/nextcloud/data
    # Geef de juiste eigendom aan Apache (httpd) gebruiker
    chown -R apache:apache /var/www/html/nextcloud
    rm latest.zip -rf  # Verwijder het zip-bestand na extractie
else
    echo "Nextcloud is al geïnstalleerd op /var/www/html/nextcloud."
fi
log "configuratie nextcloud"
VHOST_CONF="${APACHE_CONF_DIR}/nextcloud.conf"
VHOST_CONTENT=$(cat <<EOF
<VirtualHost *:80>
  ServerAdmin webmaster@${DNS_NEXTCLOUD}
  ServerName ${DNS_NEXTCLOUD}
  ServerAlias www.${DNS_NEXTCLOUD}
  DocumentRoot /var/www/html/nextcloud/

  <Directory /var/www/html/nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews

    <IfModule mod_dav.c>
    Dav off
    </IfModule>

  </Directory>
    ErrorLog ${APACHE_LOG_DIR}/${DNS_NEXTCLOUD}_error.log
    CustomLog ${APACHE_LOG_DIR}/${DNS_NEXTCLOUD}_access.log combined
</VirtualHost>
EOF
)
echo "${VHOST_CONTENT}" |  tee "${VHOST_CONF}"

# SELinux-configuratie
restorecon -RF  /var/www/html/nextcloud/
chcon -R -t httpd_sys_rw_content_t /var/www/html/nextcloud/



# Controleren of het configuratiebestand niet bestaat of leeg is
if [ -f "/var/www/html/nextcloud/config/CAN_INSTALL" ]; then
    log "Configuratiebestand is leeg of bestaat niet. Voer de installatie uit."
    # Voer de installatie van Nextcloud uit
    cd /var/www/html/nextcloud/
    log "-----------installatie wizard nextcloud-----------------"
    sudo -u apache php occ maintenance:install \
    --database='mysql' --database-name="${db_name}" \
    --database-user="${db_user}" --database-pass="${db_password}" \
    --admin-user="${nextcloudRootuser}" --admin-pass="${nextcloudRootpassword}" --database-host="${STATIC_IP_DB}"
    cd /var/www/html/nextcloud/
    log  "trusted domeinen toevoegen voor ${DNS_NEXTCLOUD} "
    sudo -u apache php occ config:system:set trusted_domains 1 --value="${DNS_NEXTCLOUD}"
    
    # Gebruikersaccount aanmaken met wachtwoord
    log "Gebruikersaccount aanmaken met wachtwoord  KAN LANG DUREN"
    su -s /bin/sh apache -c "php occ user:add --password-from-env --display-name='${nextclouduser}' '${nextclouduser}'"
    # Installeer alleen de kalenderapplicatie
    log "isntalleren van calender  KAN LANG DUREN"
    sudo -u apache php occ app:install calendar --verbose
    # Installeer de Forms-app
    log "installeren van forms KAN LANG DUREN"
    sudo -u apache php occ app:install forms --verbose
    
    sudo -u apache php occ config:system:set overwrite.cli.url --value="https://nextcloud.g07-blame.internal" 
    sudo -u apache php occ config:system:set overwriteprotocol --value="https"
    log "aanmaken kalender"
    sudo -u apache php occ dav:create-calendar ${nextclouduser} plopkoek
else
    log "Configuratiebestand bevat al gegevens. De installatie wordt niet uitgevoerd."
fi

systemctl restart vaultwarden
log "vaultwarden service is geactiveerd en actief" 
log "herstarten van httpd service"
systemctl restart httpd
log "Provisioning voltooid zonder fouten"
