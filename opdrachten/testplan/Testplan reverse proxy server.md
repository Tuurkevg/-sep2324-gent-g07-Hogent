# Testplan: Linux reverse proxy server

- Auteur(s) testplan: Arhtur Van Ginderachter
- Co-auteur: Lucas Ludueña-Segre

**Opgelet**: de output kan verschillen in een echte opstelling, het gegeven "Verwacht resultaat" voor een test is slechts een placeholder voor een mogelijk geldige output. Het apparaat waar de test op wordt uitgevoerd, staat telkens tussen haakjes in de titel van elke test/stap.

## 1. Start de reverse proxy server op via Vagrant. *(Hostmachine reverse proxy VM)*

- Opstarten van Linux vm met vagrant. + stellen van correcte bridge adapter. (de adapter kan verschillen van gebruiker tot gebruiker):

```
$ vagrant up rp
Bringing machine 'rp' up with 'virtualbox' provider...
==> rp: Importing base box 'bento/almalinux-9'...
Progress: 50%1
==> rp: Matching MAC address for NAT networking...
==> rp: Checking if box 'bento/almalinux-9' version '202401.31.0' is up to date...
==> rp: Setting the name of the VM: Vagrant-VirtualeMachine_rp_1711560739121_9919
==> rp: Fixed port collision for 22 => 2222. Now on port 2200.
==> rp: Clearing any previously set network interfaces...
==> rp: Available bridged network interfaces:
```

## 2. Log in via SSH. *(Hostmachine reverse proxy VM)*

```
$ vagrant ssh rp

This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
[vagrant@rp ~]$ 
```

## 3. Verifiëer dat SELinux actief is. *(Reverse proxy VM)*

```
[vagrant@rp ~]$ getenforce 
Enforcing
```

## 4. Verifiëer de netwerkinstellingen. *(Reverse proxy VM)*

- Het IP-adres moet overeen komen met de statische IP-adres `STATIC_IP_WEB` in het algemene provisioningscript `common.sh`:

```
[vagrant@rp ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a7:59:a3 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 85896sec preferred_lft 85896sec
    inet6 fe80::693c:8bd4:93ec:4bd3/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:52:ce:76 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.107.164/29 brd 192.168.107.167 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe52:ce76/64 scope link 
       valid_lft forever preferred_lft forever
```

## 5. Verifiëer de firewall-instellingen. *(Reverse proxy VM)*

- Enkel http en https mogen als extra rule geaccapteerd worden:

```
[vagrant@rp ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources: 
  services: cockpit dhcpv6-client http https ssh
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
```

## 6. De reverse proxy server maakt gebruik van self-signed certificates voor HTTPS. *(Reverse proxy VM)*

- Controleren van self signed certificaat met de correcte output (kies een IP-adres naar keuze, ofwel de website/extra website, of het IP-adres van de proxy zelf):

```
[vagrant@rp ~]$ openssl s_client -connect 192.168.107.164:443 -showcerts | openssl x509 -text -noout
Can't use SSL_get_servername
depth=0 C = BE, ST = Oost-Vlaanderem, L = Gent, O = Blame, OU = Blame Unit, CN = g07-blame.internal
verify error:num=18:self-signed certificate
verify return:1
depth=0 C = BE, ST = Oost-Vlaanderem, L = Gent, O = Blame, OU = Blame Unit, CN = g07-blame.internal
verify return:1
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:0c:3b:74:c1:8a:9a:fe:18:e6:ee:87:0b:07:2a:e2:ce:e4:75:72
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = BE, ST = Oost-Vlaanderem, L = Gent, O = Blame, OU = Blame Unit, CN = g07-blame.internal
        Validity
            Not Before: Mar 27 17:48:55 2024 GMT
            Not After : Mar 27 17:48:55 2025 GMT
        Subject: C = BE, ST = Oost-Vlaanderem, L = Gent, O = Blame, OU = Blame Unit, CN = g07-blame.internal
...
```

## 7. Er is enkel een HTTPS-verbinding tussen client en reverse proxy server. *(Client-VM)*

- Deze test wordt uitgevoerd vanuit een client. Controleren of enkel https mogelijk vanuit client. (HTTP mag niet werken en moet een redirect krijgen (code 301):

```
$ curl -I http://g07-blame.internal
HTTP/1.1 301 Moved Permanently
Date: Wed, 27 Mar 2024 18:19:19 GMT
Content-Type: text/html
Content-Length: 162
Connection: keep-alive
Location: https://g07-blame.internal/
```

## 8. Tussen de reverse proxy server en de webserver is er enkel een HTTP-verbinding. *(Reverse proxy VM)*

- HTTPS krijgt geen reactie:

```
[vagrant@rp ~]$ curl https://192.168.107.150
curl: (7) Failed to connect to 192.168.107.150 port 443: No route to host
```

- 403 Forbidden:

```
[vagrant@rp ~]$ curl -I http://192.168.107.150
HTTP/1.1 403 Forbidden
Date: Wed, 27 Mar 2024 18:28:00 GMT
Server: Apache/2.4.57 (AlmaLinux)
Last-Modified: Sat, 09 Oct 2021 17:49:21 GMT
ETag: "1249-5cdef1d990a40"
Accept-Ranges: bytes
Content-Length: 4681
Content-Type: text/html; charset=UTF-8

```

- HTTP wordt aanvaard:

```
[vagrant@rp ~]$ curl http://192.168.107.150

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head>
		<title>Test Page for the HTTP Server on AlmaLinux</title>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<style type="text/css">
			/*<![CDATA[*/
...
```

## 9. De reverse proxy server maakt gebruik van HTTP/2 over TLS. *(Client-VM)*

- De HTTP/2-connectie is mogelijk en de standaard optie voor het verbinden met TLS:

```
$ curl -I --insecure --http2-prior-knowledge https://192.168.107.164
HTTP/2 403 
date: Wed, 27 Mar 2024 18:32:19 GMT
content-type: text/html; charset=UTF-8
content-length: 4681
last-modified: Sat, 09 Oct 2021 17:49:21 GMT
etag: "1249-5cdef1d990a40"
accept-ranges: bytes

```

## 10. Als de webserver gescand wordt met nmap, geeft deze geen informatie over de versie van de webserver EN geen http header info (uitbreiding). *(Reverse proxy VM)*

- `nmap`-scan van de reverse proxy server:

```
[vagrant@rp ~]$ nmap 192.168.107.164
Starting Nmap 7.92 ( https://nmap.org ) at 2024-03-27 18:26 UTC
Nmap scan report for g07-blame.internal (192.168.107.164)
Host is up (0.00034s latency).
Not shown: 995 closed tcp ports (conn-refused)
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
111/tcp  open  rpcbind
443/tcp  open  https
9090/tcp open  zeus-admin

Nmap done: 1 IP address (1 host up) scanned in 0.16 seconds
```

- Extra controle via `curl`, de versie en naam van de Nginx-server mag niet zichtbaar zijn:

```
[vagrant@rp ~]$ curl -I --insecure https://192.168.107.164
HTTP/2 403 
date: Wed, 27 Mar 2024 18:32:19 GMT
content-type: text/html; charset=UTF-8
content-length: 4681
last-modified: Sat, 09 Oct 2021 17:49:21 GMT
etag: "1249-5cdef1d990a40"
accept-ranges: bytes

```