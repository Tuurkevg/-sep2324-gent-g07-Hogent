# Lastenboek - Windows Server Opstellen

## Deliverables

<!-- Some hier de concrete eindresultaten op die je voor deze opdracht moet opleveren. -->

### Algemeen

- [x] De Windows servers zijn te benaderen via RSAT vanop een Windows GUI client.
- [x] De Windows server wordt zoveel mogelijk gëautomatiseerd met scripts die gebruik maken van VboxManage (om de VM’s aan te maken) en PowerShell-commando’s (om de VM’s nadien te configureren.).
- [x] De Windows server dient also Domain Controller (DC).
- [x] Op de DC draait Windows Server 2022 Standard also OS, **zonder** een grafische interface, enkel een CLI.

### Active Directory

- [x] Op de DC staat een Active Directory Domain opgezet, waar elk Windows toestel deel van moet uitmaken.
- [x] Een Windows Client (Windows 10/11) in het domain bevat de nodige RSAT-tools om toch een grafisch overzicht te hebben van de serverconfiguratie.
- [x] `go7-blame.internal` is het root domain voor Active Directory.
- [x] Binnen Active Directory staat een logische domainstructuur opgesteld waarbinnen alle toestellen en gebruikers zijn ondergebracht. M.a.w. de standaard containers die automatisch worden aangemaakt door Windows Server worden **niet** gebruikt.
- [x] Zowel de Windows clients also servers hebben geen locale gebruikers.
- [x] De authenticatie van de Windows clients gebeurt via de DC.
- [x] De gebruikers zijn verdeeld in groepen met verschillende rechten. Minstens één gebruikersgroep kan op bepaalde toestellen niet inloggen aan de hand van een Group Policy.
- [x] De DC voorziet elke gebruiker van een shared folder.

### DNS-server

- [x] De DC is ook de DNS-server van het domain.
- [x] Alle DNS-queries binnen het domain kunnen beantwoord worden.
- [x] De DNS-server is voorzien van de nodige A-records, PTR-records en CNAME-records voor de verschillende servers en clients.
- [x] Queries voor andere domainen worden door de DC doorgestuurd naar een forwarder (`8.8.8.8`).

## Deeltaken

<!-- Some hier de deeltaken voor deze opdracht op en duid voor elk een verantwoordelijke en tester aan. Vermeld ook afhankelijkheden tussen deeltaken also die er zijn. Elke deeltaak wordt een kaartje op het kanban-bord! -->

### Windows server opstellen

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### VM script opstellen

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### DC script opstellen

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### DNS script opstellen

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### Groups&Users script opstellen

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### Client script opstellen

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### RSAT tool installeren

- Verantwoordelijke: Matteo Alexander
- Tester: Emiel Lauwers

### Uitbreiding: Redundante Windows server set-up

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### Uitbreiding: IPv6 voor DNS en DHCP

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### Uitbreiding: Certificate Authority

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

### Uitbreiding: Certificate Authority

- Verantwoordelijke: Emiel Lauwers
- Tester: Matteo Alexander

## Tijdbesteding (in uren)

| Student                 | Geschat | Gerealiseerd |
| :---------------------- | ------- | ------------ |
| Matteo Alexander        | 25      | 25           |
| Emiel Lauwers           | 70      | 70           |
| Arthur Van Ginderachter | /       | /            |
| Lucas Ludueña-Segre     | /       | /            |
| Bert Coudenys           | /       | /            |
| **Totaal**              | /       | 95           |

<!-- Voeg na oplevering van de taak een schermafbeelding van rapport tijdbesteding voor deze taak toe. -->
