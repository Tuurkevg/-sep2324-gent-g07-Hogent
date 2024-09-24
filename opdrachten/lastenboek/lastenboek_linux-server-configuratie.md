# Lastenboek - Linux Server Configuratie

## Deliverables

<!-- Som hier de concrete eindresultaten op die je voor deze opdracht moet opleveren. -->

### Algemeen

- [x] De Linux servers beschikken over de laatste versie van AlmaLinux op dit moment.
- [x] De Linux servers mogen enkel over een CLI beschikken.
- [x] Op de Linux servers staat SELinux aan.
- [x] De Linux servers zijn benaderbaar via SSH.
- [x] Op de Linux servers kan men enkel inloggen door middel van SSH keys, nooit met het root account.

### Databank

- [x] De databank-server draait een MariaDB-databank.
- [x] Enkel poorten nodig voor de databank (3306) en SSH (22) mogen open staan in de firewall.
- [x] De databank-server aanvaardt enkel connecties van (het IP-adres van) de webserver. Databank clients op andere devices worden sowieso geweigerd.

### Webserver

- [x] De webserver draait een Apache-webserver.
- [x] De webserver maakt gebruik van Wordpress als CMS.
- [x] De CMS maakt gebruik van de databank op de databankserver.
- [x] Men kan op de webserver inloggen en een post aanmaken.

### Reverse proxy

- [x] De reverse proxy server (in de DMZ) draait een Nginx reverse proxy server.
- [x] De reverse proxy server maakt gebruik van self-signed certificates voor HTTPS.
- [x] Er is enkel een HTTPS-verbinding tussen client en reverse proxy server.
- [x] Tussen de reverse proxy server en de webserver is er enkel een HTTP-verbinding.
- [x] De reverse proxy server maakt gebruik van HTTP/2 over TLS.
- [x] Als de webserver gescand wordt met nmap, geeft deze geen informatie over de versie van de webserver.

### TFTP-server

- [x] De TFTP-server is geïnstalleeerd.
- [x] Netwerktoestellen worden via deze TFTP-server geconfigureerd.
- [x] De automatische installatie kopieert de netwerkconfiguraties naar de juiste map op deze server.

### Uitbreidingen
- [x] Certificate Authority (RP)
- [x] Reverse proxy hardening
- [x] Extra webserver
- [x] Vaultwarden
- [x] Nextcloud
- [x] IPv6

## Deeltaken

<!-- Som hier de deeltaken voor deze opdracht op en duid voor elk een verantwoordelijke en tester aan. Vermeld ook afhankelijkheden tussen deeltaken als die er zijn. Elke deeltaak wordt een kaartje op het kanban-bord! -->

### Basis netwerk configuratie in orde bringen.

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Lucas Ludueña-Segre

### LSC - Creatie template (Initiële installatie + SSH Configuratie)

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Lucas Ludueña-Segre

### LSC - Databank configuratie (MariaDB)

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Matteo Alexander

### LSC - Reverse proxy configuratie

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Lucas Ludueña-Segre

#### aanmaken van automatisch hernieuwen CRT certificaat script

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Lucas Ludueña-Segre

### LSC - Webserver configuratie

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Matteo Alexander

#### firewall, alleen verkeer op poort door ReverseProxy

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Lucas Ludueña-Segre

### LSC - TFTP-server configuratie

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Lucas Ludueña-Segre

### Uitbreiding - Reverse proxy hardening

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Lucas Ludueña-Segre

### Uitbreiding - Certificate Authority (RP)

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Matteo Alexander

### Uitbreiding - Nextcloud

- Verantwoordelijke: Arthur Van Ginderachter/Lucas Ludueña-Segre
- Tester: Matteo Alexander

### Uitbreiding - TFTP naar bridged vm

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Matteo Alexander

### Uitbreiding - Extra webserver

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Matteo Alexander

### Uitbreiding - Vaultwarden

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Matteo Alexander

### Uitbreiding - IPv6

- Verantwoordelijke: Arthur Van Ginderachter
- Tester: Matteo Alexander

## Tijdbesteding (in uren)

| Student                 | Geschat | Gerealiseerd |
| :---------------------- | ------- | ------------ |
| Matteo Alexander        | 30      | 35           |
| Emiel Lauwers           | /       | /            |
| Arthur Van Ginderachter | 100     | 100          |
| Lucas Ludueña-Segre     | 50      | 50           |
| Bert Coudenys           | 3       | 3            |
| **Totaal**              | 183     | 188          |

<!-- Voeg na oplevering van de taak een schermafbeelding van rapport tijdbesteding voor deze taak toe. -->
