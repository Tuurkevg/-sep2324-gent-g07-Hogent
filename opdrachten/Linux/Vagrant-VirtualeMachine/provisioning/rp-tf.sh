#! /bin/bash
#
# Provisioning script for reverse proxy server

#------------------------------------------------------------------------------
# Bash settings
#------------------------------------------------------------------------------
#sudo useradd -r nginx
# Enable "Bash strict mode"
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
readonly NGINX_VERSION="1.26.0"
#------------------------------------------------------------------------------
# "Imports"
#------------------------------------------------------------------------------

# Actions/settings common to all servers
source ${PROVISIONING_SCRIPTS}/common.sh

# Nginx configuratiebestand
readonly nginx_conf_file="/etc/nginx/conf.d/${DOMAIN_NAME}.conf"
# cronjob automatisch hernieuwen van ssl certificaat
readonly CRONJOB="0 0 1 */6 * openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:4096 -keyout /etc/nginx/ssl/${DOMAIN_NAME}.key -out \"/etc/nginx/ssl/${DOMAIN_NAME}.crt\" -subj \"/C=BE/ST=Oost-Vlaanderem/L=Gent/O=Blame/OU=Blame Unit/CN=${DOMAIN_NAME}\" && service nginx reload"
readonly TFTP_DIRECTORY="/etc/tft/sharedfolder"
#------------------------------------------------------------------------------
# Provision server
#------------------------------------------------------------------------------

log "=== Starten van server-specifieke provisioning-taken op ${HOSTNAME} ==="

# Controleer of de basis dependency packages geïnstalleerd zijn en installeer indien nodig
log "controleren of de basis dependency packages geïnstalleerd zijn en installeer indien nodig"
# Controleer of een van de vereiste pakketten al is geïnstalleerd
if ! rpm -q gcc gcc-c++ make zlib-devel pcre-devel openssl-devel libxslt-devel gd-devel perl-ExtUtils-Embed &>/dev/null; then
    log "Een of meer vereiste pakketten ontbreken. Installeren..."
    dnf install -y gcc gcc-c++ make zlib-devel pcre-devel openssl-devel libxslt-devel gd-devel perl-ExtUtils-Embed
fi


# Controleer of Nginx al is gedownload  met de juiste versie
log "controleren of Nginx al isgedownload  met de juiste versie"
if [ -x "/opt/nginx/sbin/nginx" ]; then
    INSTALLED_VERSION="$(/opt/nginx/sbin/nginx -v 2>&1 | awk -F'/' '{print $2}')"
    if [ "$INSTALLED_VERSION" = "$NGINX_VERSION" ]; then
        log "Nginx $NGINX_VERSION is al geïnstalleerd."
        systemctl restart nginx
    fi
    else
        # Controleer of de bestanden al zijn gedownload
        log "controleren of ${NGINX_VERSION} al geinstalleerd is"
        if [ ! -f nginx-$NGINX_VERSION.tar.gz ] || [ ! -f master.zip ]; then
            # Download Nginx en headers-more-nginx-module
            log "Download Nginx en headers-more-nginx-module"
            wget -q http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
            wget -q https://github.com/openresty/headers-more-nginx-module/archive/master.zip

            # Controleer of de bestanden zijn gedownload
            if [ ! -f nginx-$NGINX_VERSION.tar.gz ] || [ ! -f master.zip ]; then
                log  "Fout: Kon Nginx of headers-more-nginx-module niet downloaden."
                exit 1
            fi
            # Extract Nginx en headers-more-nginx-module
            tar -xzf nginx-$NGINX_VERSION.tar.gz
            unzip -q master.zip
        fi
        cd nginx-$NGINX_VERSION
        log "compilen van nginx en module extra nginx met make file"
        ./configure --prefix=/etc/nginx \
                    --conf-path=/etc/nginx/nginx.conf \
                    --sbin-path=/opt/nginx/sbin/nginx \
                    --modules-path=/opt/nginx/modules \
                    --add-module=../headers-more-nginx-module-master \
                    --with-http_ssl_module \
                    --with-http_v2_module \
                    --with-http_sub_module \
                    --with-http_gzip_static_module \
                    --with-file-aio \
                    --with-threads \
                    --with-http_stub_status_module \
                    --error-log-path=/var/log/nginx/error.log \
                    --http-log-path=/var/log/nginx/access.log \


        make
        make install
        # Voeg systemd-servicebestand toe als het nog niet bestaat
        if [ ! -f "/etc/systemd/system/nginx.service" ]; then
            log "Voeg systemd-servicebestand toe voor nginx.service"
            echo "[Unit]
                Description=Nginx HTTP server
                After=network.target

                [Service]
                Type=forking
                ExecStart=/opt/nginx/sbin/nginx
                ExecReload=/opt/nginx/sbin/nginx -s reload
                ExecStop=/opt/nginx/sbin/nginx -s stop
                PrivateTmp=true

                [Install]
                WantedBy=multi-user.target" | tee /etc/systemd/system/nginx.service > /dev/null
            systemctl daemon-reload
        fi
        # Toevoegen van het Nginx pad aan ~/.bashrc indien nog niet aanwezig
        if ! grep -q "/opt/nginx/sbin" ~/.bashrc; then
            echo 'export PATH=/opt/nginx/sbin:$PATH' >> ~/.bashrc
            log "Nginx pad is toegevoegd aan ~/.bashrc voor root"
            cd ~ 
           bash ".bashrc" 
        else
            log "Nginx pad is al aanwezig in ~/.bashrc voor root"
        fi
        # Toepassen van wijzigingen voor de root user.
        log "Schoonmaak en verwijder gedownloade bestanden"
        # Controleer of er bestanden met "nginx" in de naam in de directory aanwezig zijn
        if ls /home/vagrant/*nginx* &>/dev/null; then
            # Verwijder mappen en bestanden die beginnen met "nginx"
            rm -v /home/vagrant/headers-more-nginx-module-master /home/vagrant/master.zip /home/vagrant/nginx-${NGINX_VERSION} /home/vagrant/nginx-${NGINX_VERSION}.tar.gz -rf
            log "Bestanden met 'nginx' in de naam zijn succesvol verwijderd."
        fi
fi  

###############################################################################################################################################
# Controleer of de basis dependency packages geïnstalleerd zijn en installeer indien nodig
log "controleren of de basis dependency packages geïnstalleerd zijn en installeer indien nodig"
# Controleer of een van de vereiste pakketten al is geïnstalleerd
if ! rpm -q gcc gcc-c++ make zlib-devel pcre-devel openssl-devel libxslt-devel gd-devel perl-ExtUtils-Embed &>/dev/null; then
    log "Een of meer vereiste pakketten ontbreken. Installeren..."
    dnf install -y gcc gcc-c++ make zlib-devel pcre-devel openssl-devel libxslt-devel gd-devel perl-ExtUtils-Embed
fi


# Controleer of Nginx al is gedownload  met de juiste versie
log "controleren of Nginx al isgedownload  met de juiste versie"
if [ -x "/opt/nginx/sbin/nginx" ]; then
    INSTALLED_VERSION="$(/opt/nginx/sbin/nginx -v 2>&1 | awk -F'/' '{print $2}')"
    if [ "$INSTALLED_VERSION" = "$NGINX_VERSION" ]; then
        log "Nginx $NGINX_VERSION is al geïnstalleerd."
        systemctl restart nginx
    fi
    else
        # Controleer of de bestanden al zijn gedownload
        log "controleren of ${NGINX_VERSION} al geinstalleerd is"
        if [ ! -f nginx-$NGINX_VERSION.tar.gz ] || [ ! -f master.zip ]; then
            # Download Nginx en headers-more-nginx-module
            log "Download Nginx en headers-more-nginx-module"
            wget -q http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
            wget -q https://github.com/openresty/headers-more-nginx-module/archive/master.zip

            # Controleer of de bestanden zijn gedownload
            if [ ! -f nginx-$NGINX_VERSION.tar.gz ] || [ ! -f master.zip ]; then
                log  "Fout: Kon Nginx of headers-more-nginx-module niet downloaden."
                exit 1
            fi
            # Extract Nginx en headers-more-nginx-module
            tar -xzf nginx-$NGINX_VERSION.tar.gz
            unzip -q master.zip


            sed -i 's/^static u_char ngx_http_server_string.*$/static u_char ngx_http_server_string[] = "Server: IK HAAT WINDOWS" CRLF;/' /home/vagrant/nginx-${NGINX_VERSION}/src/http/ngx_http_header_filter_module.c
            sed -i 's/^static u_char ngx_http_server_full_string.*$/static u_char ngx_http_server_full_string[] = "Server: IK HAAT WINDOWS NOG HARDER DAN GISTEREN" CRLF;/' /home/vagrant/nginx-${NGINX_VERSION}/src/http/ngx_http_header_filter_module.c
            sed -i 's/^static u_char ngx_http_server_build_string.*$/static u_char ngx_http_server_build_string[] = "Server: IK HAAT WINDOWS NOG HARDER DAN GISTEREN" CRLF;/' /home/vagrant/nginx-${NGINX_VERSION}/src/http/ngx_http_header_filter_module.c
        fi
        cd nginx-$NGINX_VERSION
        log "compilen van nginx en module extra nginx met make file"
        ./configure --prefix=/etc/nginx \
                    --conf-path=/etc/nginx/nginx.conf \
                    --sbin-path=/opt/nginx/sbin/nginx \
                    --modules-path=/opt/nginx/modules \
                    --add-module=../headers-more-nginx-module-master \
                    --with-http_ssl_module \
                    --with-http_v2_module \
                    --with-http_sub_module \
                    --with-http_gzip_static_module \
                    --with-file-aio \
                    --with-threads \
                    --with-http_stub_status_module \
                    --error-log-path=/var/log/nginx/error.log \
                    --http-log-path=/var/log/nginx/access.log \


        make
        make install
        # Voeg systemd-servicebestand toe als het nog niet bestaat
        if [ ! -f "/etc/systemd/system/nginx.service" ]; then
            log "Voeg systemd-servicebestand toe voor nginx.service"
            echo "[Unit]
                Description=Nginx HTTP server
                After=network.target

                [Service]
                Type=forking
                ExecStart=/opt/nginx/sbin/nginx
                ExecReload=/opt/nginx/sbin/nginx -s reload
                ExecStop=/opt/nginx/sbin/nginx -s stop
                PrivateTmp=true

                [Install]
                WantedBy=multi-user.target" | tee /etc/systemd/system/nginx.service > /dev/null
            systemctl daemon-reload
        fi
        # Toevoegen van het Nginx pad aan ~/.bashrc indien nog niet aanwezig
        if ! grep -q "/opt/nginx/sbin" ~/.bashrc; then
            echo 'export PATH=/opt/nginx/sbin:$PATH' >> ~/.bashrc
            log "Nginx pad is toegevoegd aan ~/.bashrc voor root"
            cd ~ 
           bash ".bashrc" 
        else
            log "Nginx pad is al aanwezig in ~/.bashrc voor root"
        fi
        # Toepassen van wijzigingen voor de root user.
        log "Schoonmaak en verwijder gedownloade bestanden"
        # Controleer of er bestanden met "nginx" in de naam in de directory aanwezig zijn
        if ls /home/vagrant/*nginx* &>/dev/null; then
            # Verwijder mappen en bestanden die beginnen met "nginx"
            rm -v /home/vagrant/headers-more-nginx-module-master /home/vagrant/master.zip /home/vagrant/nginx-${NGINX_VERSION} /home/vagrant/nginx-${NGINX_VERSION}.tar.gz -rf
            log "Bestanden met 'nginx' in de naam zijn succesvol verwijderd."
        fi
fi  

###############################################################################################################################################

# Genereren van certificaat
if [ ! -f "/etc/nginx/ssl/${DOMAIN_NAME}.crt" ]; then
	mkdir -p /etc/nginx/ssl
    # Het certificaat bestaat nog niet, dus genereren we er een
    openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:4096 -keyout /etc/nginx/ssl/${DOMAIN_NAME}.key -out "/etc/nginx/ssl/${DOMAIN_NAME}.crt" -subj "/C=BE/ST=Oost-Vlaanderem/L=Gent/O=Blame/OU=Blame Unit/CN=${DOMAIN_NAME}"
fi


#crontab voor hernieuwen certificaat TESTEN AUB
# Controleer of de cronjob al in de crontab staat
log "crontab controleren of die er al is voor hernieuwen certificaat:"
if ! crontab -l | grep -qF "$CRONJOB"; then
    # Voeg de cronjob toe aan de crontab van de root-gebruiker
    log "automatich vernieuwen certificaat na 6 maanden Cronjob toevoegen voor automatisch hernieuwen van SSL-certificaat"
    echo "$CRONJOB" | crontab -
fi

# Controleer of het Nginx configuratiebestand al bestaat
log "configureren van van het domein ${DOMAIN_NAME} van NGINX"
# Genereer de inhoud     van het Nginx configuratiebestand OAD BALANICNG EXTRA SERVER IP INGEVEN ZIE HIERONDER BIJ UPDSTREAM!
nginx_conf_content="
# Upstream-groep voor load balancing op de extra webserver
upstream backend_extra {
    ip_hash; # consistent zelfde host naar zelfde wordpress server
    server ${STATIC_IP_EXTRA}; #backup server want combinatie met nextcloud wordpress plus extra website.
    server ${STATIC_IP_WEB};
   
    # Voeg hier extra servers toe indien nodig
}

# websever voor wordpress
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN_NAME} www.${DOMAIN_NAME};

    location / {
    #   proxy_pass http://${STATIC_IP_WEB};
        proxy_pass http://backend_extra;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        	# Redirect naar HTTPS
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN_NAME} www.${DOMAIN_NAME};

    ssl_certificate /etc/nginx/ssl/${DOMAIN_NAME}.crt;
    ssl_certificate_key /etc/nginx/ssl/${DOMAIN_NAME}.key;

    location / {
    #   proxy_pass http://${STATIC_IP_WEB};
        proxy_pass http://backend_extra;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# extra webserver
server {
    listen 80;
    listen [::]:80;
    server_name ${EXTRA_WEBSERVER} www.${EXTRA_WEBSERVER};

    location / {
        proxy_pass http://backend_extra;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        	# Redirect naar HTTPS
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${EXTRA_WEBSERVER} www.${EXTRA_WEBSERVER};

    ssl_certificate /etc/nginx/ssl/${DOMAIN_NAME}.crt;
    ssl_certificate_key /etc/nginx/ssl/${DOMAIN_NAME}.key;

    location / {
        proxy_pass http://backend_extra;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# NEXTCLOUD SERVER
server {
    listen 80;
    listen [::]:80;
    server_name ${DNS_NEXTCLOUD} www.${DNS_NEXTCLOUD};

    location / {
        proxy_pass http://${STATIC_IP_EXTRA};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        	# Redirect naar HTTPS
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DNS_NEXTCLOUD} www.${DNS_NEXTCLOUD};

    ssl_certificate /etc/nginx/ssl/${DOMAIN_NAME}.crt;
    ssl_certificate_key /etc/nginx/ssl/${DOMAIN_NAME}.key;

    location / {
        proxy_pass http://${STATIC_IP_EXTRA};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}

# VAULTWARDEN SERVER
server {
    listen 80;
    listen [::]:80;
    server_name ${DNS_VAULTWARDEN} www.${DNS_VAULTWARDEN};

    location / {
        proxy_pass http://${STATIC_IP_EXTRA}:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DNS_VAULTWARDEN} www.${DNS_VAULTWARDEN};

    ssl_certificate /etc/nginx/ssl/${DOMAIN_NAME}.crt;
    ssl_certificate_key /etc/nginx/ssl/${DOMAIN_NAME}.key;

    location / {
        proxy_pass http://${STATIC_IP_EXTRA}:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

}
"

# Maak het Nginx configuratiebestand aan en de map voor de configuratiebestanden
mkdir -p /etc/nginx/conf.d
echo "$nginx_conf_content" | tee "$nginx_conf_file" > /dev/null

log "Nginx configuratie succesvol toegevoegd voor $STATIC_IP_RP met WordPress op server $STATIC_IP_WEB. voor de ${EXTRA_WEBSERVER} met load balancing op server ${STATIC_IP_EXTRA}"
log "voor de ${DNS_NEXTCLOUD} op server  ${STATIC_IP_EXTRA}"

ip link set dev "$INTERFACE" down && ip link set dev "$INTERFACE" up
log "Firewall controleren voor Nginx"
# firewall openzetten voo rhttp en https
if !  firewall-cmd --list-services | grep -E "https|http" > /dev/null; then
    log "Firewall openzetten voor http en https"
    firewall-cmd --add-service=https --add-service=http --permanent
    firewall-cmd --reload
fi

# Controleer de huidige staat van de httpd_can_network_connect boolean
if !  getsebool httpd_can_network_connect | grep -q -- 'httpd_can_network_connect --> on'; then
     setsebool -P httpd_can_network_connect on
fi

log "signature naar off en server_tokens naar off --> veiligheid NMAP en sniffing"
# Controleer of de regels al bestaan in het Nginx configuratiebestand voor de versie van nginx
log "Controleer of de regels al bestaan in het Nginx configuratiebestand voor de versie van nginx en voor http header te verbergen"

# Controleer of de regels al voor configuratie reverse proxy doorsturingen nar correcte websites
if ! grep -q "include /etc/nginx/conf.d/" /etc/nginx/nginx.conf; then
    sed -i '/^http {/a include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
fi


# Controleer of de 'more_set_headers' regels al bestaan
if ! grep -q "more_set_headers 'Server: Apache';" /etc/nginx/nginx.conf; then
    # Voeg de 'more_set_headers' regels toe als deze ontbreken
    sed -i '/^http {/a \    more_set_headers '"'"'Server: Apache'"'"';' /etc/nginx/nginx.conf
fi

if ! grep -q "more_set_headers 'X-Powered-By: PHP/7.4.3';" /etc/nginx/nginx.conf; then
    # Voeg de 'more_set_headers' regels toe als deze ontbreken
    sed -i '/^http {/a \    more_set_headers '"'"'X-Powered-By: PHP/7.4.3'"'"';' /etc/nginx/nginx.conf
fi

# Zet server_tokens uit
if ! grep -q "server_tokens off;" /etc/nginx/nginx.conf; then
    # Voeg server_tokens uit regel toe als deze ontbreekt
    sed -i '/^http {/a \    server_tokens off;' /etc/nginx/nginx.conf
fi
# Controleer of de 'more_clear_headers Server' regel al bestaat
if ! grep -q "more_clear_headers Server;" /etc/nginx/nginx.conf; then
    # Voeg de 'more_clear_headers Server' regel toe als deze ontbreekt
    sed -i '/^http {/a \    more_clear_headers Server;' /etc/nginx/nginx.conf
fi
# Controleer of de service actief is. Zoniet, stel hem in op actief
log "starten van nginx service"
if !  systemctl is-active --quiet nginx; then
     systemctl start nginx
else
    systemctl restart nginx
fi

# Controleer of de service enabled is. Zoniet, enable hem
if !  systemctl is-enabled --quiet nginx; then
     systemctl enable nginx
fi


log "---------------------nginx service is geactiveerd en actief-------------------------"


log "#--------------------------------------------------TFTP SERVER INSTALLERE-------------------------------------------------------------------------------------------------#"
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
log "DHCP uitschakelen voor interface $INTERFACE EN VLAN 13 TAGGED EN TFTP op native untagged"

# Maak eerst de VLAN-interface aan voor VLAN 13
interface_file_vlan="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE.13"
cat << EOF > "$interface_file_vlan"
ONBOOT=yes
DEVICE=$INTERFACE.13
BOOTPROTO=none
VLAN=yes
IPADDR=$STATIC_IP_RP
NETMASK=$NETMASK_VLAN13
GATEWAY=$GATEWAY_VLAN13
DNS1=$DNS_SERVER
DNS2=$DNS_SERVER_6
IPV6INIT=yes
IPV6_AUTOCONF=no
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6ADDR=$STATIC_IP_RP6
IPV6ADDR_SECONDARIES="$STATIC_IP_RP6/$PREFIXLEN"
IPV6_DEFAULTGW=$GATEWAY_VLAN13_6
EOF

log "Configuratie voor VLAN 13-interface ($INTERFACE.13) is aangemaakt."

# Nu de configuratie voor het ongetagde verkeer (TFTP)
interface_file_native="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"
cat << EOF > "$interface_file_native"
ONBOOT=yes
DEVICE=$INTERFACE
BOOTPROTO=none
IPADDR=$STATIC_IP_TFTP
NETMASK=$NETMASK_VLAN1
DNS1=$DNS_SERVER
DNS2=$DNS_SERVER_6
IPV6INIT=yes
IPV6_AUTOCONF=no
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6ADDR=$STATIC_IP_TFTP6
IPV6ADDR_SECONDARIES="$STATIC_IP_TFTP6/$PREFIXLEN"
EOF

log "Configuratie voor native untagged verkeer ($INTERFACE) is aangemaakt."

log "Netwerkconfiguratie is bijgewerkt."


#gebruik enkel bridge netwerk voor communicatie door metrci vooran gop 1 te zetten
# Controleer of de route al is toegevoegd voor VLAN 42 of VLAN 1
if ! grep -q -E "default via $GATEWAY_VLAN13 dev $INTERFACE|default via $GATEWAY_VLAN1 dev $INTERFACE" "/etc/sysconfig/network-scripts/route-eth1.13" &> /dev/null; then
    # Voeg de route voor VLAN 42 toe aan het routebestand
        echo "default via $GATEWAY_VLAN13 dev $INTERFACE.13 metric 1" | tee -a "/etc/sysconfig/network-scripts/route-eth1.13" > /dev/null
    #log "Route voor VLAN 13 toegevoegd aan /etc/sysconfig/network-scripts/route-eth1"
    
    # Voeg de route voor VLAN 1 toe aan het routebestand
    # echo "default via $GATEWAY_VLAN1 dev $INTERFACE metric 2" | tee -a "/etc/sysconfig/network-scripts/route-eth1" > /dev/null
    # log "Route voor VLAN 1 toegevoegd aan /etc/sysconfig/network-scripts/route-eth1"

    #log "Route voor VLAN 13 of VLAN 1 bestaat al in /etc/sysconfig/network-scripts/route-eth1"
fi

# Herstart de netwerkservice om de wijzigingen toe te passen
log  "Netwerkservice herstarten"
systemctl restart NetworkManager

log "Netwerkconfiguratie voltooid.  STATTIC IP: $STATIC_IP_RP, NETMASK: $NETMASK_VLAN13, GATEWAY: $GATEWAY_VLAN13, INTERFACE: $INTERFACE. DNS-server instellen op $DNS_SERVER."

#einde netwerk static settings---------------------------------------------------------------------------------------------------------

log "Firewall controleren voor TFTP"
# firewall regels enkel toestaan vanaf vlan1!!! veiligheid risico's beperken!
ip link set dev "$INTERFACE" down && ip link set dev "$INTERFACE" up

sleep 5
# Controleren of de zone al bestaat voordat we deze maken
if ! firewall-cmd --get-zones | grep -q "native"; then
    # Aangepaste zone maken voor het native VLAN-interface
    firewall-cmd --permanent --new-zone=native 
    firewall-cmd --permanent --zone=native --change-interface="${INTERFACE}"
    firewall-cmd --reload
fi


# Controleren of de TFTP-regel nog niet is toegevoegd aan de zone van het native VLAN-interface
if ! firewall-cmd --zone=native --list-services | grep -q "tftp"; then
    log "Firewallregel voor TFTP toevoegen aan de zone van het native VLAN-interface"

    # TFTP-regel toevoegen aan de zone van het native VLAN-interface
    firewall-cmd --permanent --zone=native --add-service=tftp
     # Bronadressenregel toevoegen aan de zone van het native VLAN-interface
    firewall-cmd --permanent --zone=native --add-rich-rule='rule family="ipv4" source address="'${NETWORK_VLAN1}/${NETMASK_VLAN1}'" service name="tftp" accept'
     firewall-cmd --permanent --zone=native --add-rich-rule='rule family="ipv6" source address="'${NETWORK_VLAN1_6}/${PREFIXLEN}'" service name="tftp" accept'
    firewall-cmd --reload
fi

log "Firewallregels herladen"
firewall-cmd --reload
systemctl daemon-reload   
systemctl restart tftp
log "provisioning succes gedaan"
