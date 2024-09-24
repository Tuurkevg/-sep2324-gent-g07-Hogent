# System Engineering Project


| Naam                    | GitHub gebruikersnaam                                     |
| :---------------------- | :-------------------------------------------------------- |
| Matteo Alexander        | [MatteoAlexander](https://github.com/MatteoAlexander)     |
| Emiel Lauwers           | [Swagger-IC](https://github.com/Swagger-IC)               |
| Arthur Van Ginderachter | [Tuurkevg](https://github.com/Tuurkevg)                   |
| Lucas Ludueña-Segre     | [lucasluduenasegre](https://github.com/lucasluduenasegre) |
| Bert Coudenys           | [BertSchool](https://github.com/BertSchool)               |

Dit is de repository voor het projectvak System Engineering Project.

:exclamation: In elke map is `README.md` steeds het startpunt van de documentatie. **Neem deze goed door!**

:bulb: Bij templates wordt er gebruik gemaakt van `<!-- Markdown comments. -->`. Open deze met een teksteditor en vervang deze door wat er gevraagd wordt. Previews tonen deze comments default niet, vandaar dat het belangrijk is om een teksteditor te gebruiken.

## Voorbereiding

Volgende taken worden door **één groepslid** uitgevoerd:

- [x] Maak de centrale GitHub repo aan via de GitHub classroom link.
- [x] Voeg alle teamleden toe aan de GitHub repo.
- [x] Maak de Jira site aan en configureer deze.
- [x] Maak het kanban bord aan.

Volgende taken dienen door **elk groepslid** uitgevoerd te worden:

- Vul de tabel bovenaan dit document aan met jouw GitHub account.
- Lees de [studiewijzer](./studiewijzer.md) en alle `README.md` bestanden in de repository goed door.

Volgende taken dienen **als team** uitgevoerd te worden:

- Opstellen roadmap. Dit is een visueel overzicht van de 12 weken planning van het project. Dit kan je doen in Jira. Ten laatste tegen week 3 is een eerste draft aangemaakt.
  - Leg de werkverdeling voor de eerste week vast.
  - Voeg de planning toe aan het kanban bord: maak de juiste tickets aan.
- Lees je in en doe research voor bepaalde onderwerpen.

Op Chamilo kan je ook de slides van de kick-off terugvinden en de opname ervan herbekijken.

## Tijdens het project

Wekelijks/tweewekelijks:

- Maak een [opvolgingsrapport](./analyse/README.md) aan **voor** aanvang van het contactmoment.

Bij aanvang nieuwe deelopdracht:

- Maak een map voor de [opdracht](./opdrachten/README.md) in [opdrachten](./opdrachten/) en plaats daar alle benodigde documenten (broncode, lastenboek, testplan, testrapport, ...) in.

## Bij het afwerken van het project

Vul dit document onderaan aan met een inhoudstabel waar we alle belangrijke documenten kunnen vinden.

### Afspraken inzake Communicatie en Tools

#### Communicatieplatform:
- **Hoofdcommunicatie:** We gebruiken Discord als ons hoofdcommunicatieplatform voor directe communicatie tussen teamleden.
- **Discussie en Overleg:** Discord wordt gebruikt voor discussies, overleg en het stellen van vragen aan teamleden.

#### Projectbeheer en Opvolging:
- **Opvolging van Taken:** We maken gebruik van Jira voor het beheren en opvolgen van taken, deadlines en projectvoortgang.
- **Taaktoewijzing:** Taken worden toegewezen in Jira, waarbij elk teamlid verantwoordelijk is voor specifieke taken of subprojecten.

#### Versiebeheer:
- **Git Repository:** De projectcode en documentatie worden beheerd in een Git-repository op GitHub met branches.
- **Branching Model:** We maken gebruik van een branchingsysteem, waarbij elke functie/feature wordt ontwikkeld in een aparte branch en later samengevoegd met de hoofdcodebase via pull requests. 
- **Code Reviews:**  Arthur als verandwoordelijke hiervan controleert alle commits bij een merge request om conflicten te vermijden.

#### Tijdregistratie:
- **Registratie van Uren:** We gebruiken Jira voor het registreren van gewerkte uren per taak of project, waardoor een nauwkeurige tijdsregistratie mogelijk is.
- **lastenboek/rapporten:** Elke 2 weken worden rapporten voorbereid, waarin de voortgang, uitdagingen en behaalde doelen van die 2 week worden beschreven.

#### Samenwerking en Overleg:
- **Regelmatige Meetings:** We plannen regelmatige teamvergaderingen om de voortgang te bespreken, problemen aan te pakken en prioriteiten vast te stellen.
- **Flexibiliteit:** Indien nodig kunnen afspraken of tools worden aangepast of bijgesteld om beter te voldoen aan de behoeften van het team en het project.

Deze afspraken zullen helpen om de communicatie en samenwerking binnen het team te bevorderen en een efficiënte en gestructureerde aanpak van het project te waarborgen.

## Inhoud GitHub repo


Dit README-document biedt een uitgebreid overzicht van de structuur en inhoud van deze GitHub-repository.

## Inhoudsopgave

- [System Engineering Project](#system-engineering-project)
  - [Voorbereiding](#voorbereiding)
  - [Tijdens het project](#tijdens-het-project)
  - [Bij het afwerken van het project](#bij-het-afwerken-van-het-project)
    - [Afspraken inzake Communicatie en Tools](#afspraken-inzake-communicatie-en-tools)
      - [Communicatieplatform:](#communicatieplatform)
      - [Projectbeheer en Opvolging:](#projectbeheer-en-opvolging)
      - [Versiebeheer:](#versiebeheer)
      - [Tijdregistratie:](#tijdregistratie)
      - [Samenwerking en Overleg:](#samenwerking-en-overleg)
  - [Inhoud GitHub repo](#inhoud-github-repo)
  - [Inhoudsopgave](#inhoudsopgave)
  - [Inleiding ](#inleiding-)
  - [Structuur van de Repository ](#structuur-van-de-repository-)
    - [1. CODEOWNERS ](#1-codeowners-)
    - [2. extra-info ](#2-extra-info-)
    - [3. opdrachten ](#3-opdrachten-)
    - [4. opvolging ](#4-opvolging-)
    - [5. README.md ](#5-readmemd-)
    - [6. studiewijzer.md ](#6-studiewijzermd-)

---

## Inleiding <a name="inleiding"></a>

Deze repository herbergt een uitgebreide verzameling documenten, opdrachten, en andere materialen gerelateerd aan verschillende onderwerpen, zoals Linux-configuratie, netwerken, opvolgingsrapporten en meer. Het fungeert als een centraal punt voor het beheren en delen van informatie binnen een project of cursus.

---

## Structuur van de Repository <a name="structuur-van-de-repository"></a>

Hieronder volgt een gedetailleerde beschrijving van de verschillende onderdelen van de repository:

### 1. CODEOWNERS <a name="codeowners"></a>

Het `CODEOWNERS`-bestand vermeldt de namen van de personen die verantwoordelijk zijn voor de code in de repository. Dit is handig voor het toewijzen van verantwoordelijkheden binnen het ontwikkelteam.

### 2. extra-info <a name="extra-info"></a>

De `extra-info`-map bevat aanvullende documentatie en bronnen, voornamelijk gericht op het gebruik van Git en versiebeheer. Het omvat onder andere:

- `git.md`: Informatie en richtlijnen voor het gebruik van Git.
- `README.md`: Een gids voor de extra informatie die in deze map te vinden is.

### 3. opdrachten <a name="opdrachten"></a>

De `opdrachten`-map bevat verschillende submappen en bestanden die betrekking hebben op verschillende opdrachten en oefeningen. Hieronder vallen onder andere:

- `Addressing-Table.md`: Een tabel met adressen.
- `basis.md`: Basishandleidingen en instructies voor opdrachten.
- `img`: Afbeeldingen die relevant zijn voor de opdrachten.
- `lastenboek`: Documenten die de specificaties en eisen voor projecten vastleggen.
- `Linux`: Opdrachten gerelateerd aan Linux-configuratie.
- `Networking`: Opdrachten met betrekking tot netwerken.
- `Offerte`: Documenten en sjablonen voor het opstellen van offertes.
- `PT-backing-up-configuration-files-using-TFTP.pka`: Een Packet Tracer-bestand voor het maken van back-ups van configuratiebestanden via TFTP.
- `PT-basis-simulatie.pkt`: Een Packet Tracer-simulatie.
- `templates`: Sjablonen voor documenten en rapporten.
- `testplan`: Testplannen voor verschillende aspecten van het project.
- `testrapport`: Rapporten over de resultaten van uitgevoerde tests.

### 4. opvolging <a name="opvolging"></a>

De `opvolging`-map bevat rapporten en afbeeldingen die de voortgang en opvolging van activiteiten binnen het project weergeven. Het omvat onder andere:

- Opvolgingsrapporten voor verschillende weken.
- Afbeeldingen van kanbanborden en flowdiagrammen die de voortgang visualiseren.

### 5. README.md <a name="readme"></a>

Het `README.md`-bestand is dit document zelf. Het biedt een gedetailleerd overzicht van de structuur van de repository.

### 6. studiewijzer.md <a name="studiewijzer"></a>

Het `studiewijzer.md`-bestand bevat een uitgebreide studiewijzer en richtlijnen voor het gebruik van de repository. Het biedt informatie over het doel van de repository en hoe de verschillende materialen kunnen worden gebruikt.

---

Dit README-document biedt een uitgebreid overzicht van de structuur en inhoud van de GitHub-repository. Voor meer informatie over specifieke onderwerpen, navigeer naar de desbetreffende sectie in de inhoudsopgave hierboven.
