# Testrapport: Linux reverse proxy server

- Auteur(s) testrapport: Matteo Alexander

## Test: Algemene checks

Testprocedure:

1. Start de reverse proxy server op via Vagrant.
2. Log in via SSH.
3. Verifiëer dat SELinux actief is.
4. Verifiëer de netwerkinstellingen.
5. Verifiëer de firewall-instellingen


Verkregen resultaat:

- De opstart van de reverse proxy server verloopt foutloos.
- Er wordt via SSH ingelogd via SSH keys, niet met een (root-)wachtwoord.
- SELinux staat op actief.
- Het IP adres van eth1 komt overeen met het statische IP-adres STATIC_IP_RP in het algemene provisioningscript common.sh.

```bash	
[vagrant@rp ~]$ getenforce
Enforcing
[vagrant@rp ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:7b:6a:36 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 86237sec preferred_lft 86237sec
    inet6 fe80::7b13:90b7:fa4:e00c/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:c9:dd:95 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.107.164/24 brd 192.168.107.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fec9:dd95/64 scope link
       valid_lft forever preferred_lft forever
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


Test geslaagd:

- [x] Ja
- [ ] Nee


## Test: HTTPS-connectiviteit en Proxy-Server Communicatie

Testprocedure:

1. De reverse proxy server maakt gebruik van self-signed certificates voor HTTPS
2. Er is enkel een HTTPS-verbinding tussen client en reverse proxy server
3. Tussen de reverse proxy server en de webserver is er enkel een HTTP-verbinding
4. De reverse proxy server maakt gebruik van HTTP/2 over TLS

Verkregen resultaat:

```bash
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
            3b:8e:2f:f3:a8:3b:89:86:f7:a5:71:f6:0c:25:ae:f6:19:2a:28:d1
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = BE, ST = Oost-Vlaanderem, L = Gent, O = Blame, OU = Blame Unit, CN = g07-blame.internal
        Validity
            Not Before: Apr 23 11:41:01 2024 GMT
            Not After : Apr 23 11:41:01 2025 GMT
        Subject: C = BE, ST = Oost-Vlaanderem, L = Gent, O = Blame, OU = Blame Unit, CN = g07-blame.internal
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:c4:e1:54:24:e3:f5:cd:29:ab:2e:e3:27:51:0e:
                    09:d9:74:f3:49:b6:62:cd:15:4a:11:46:d3:e7:04:
                    6a:2a:6c:9e:fe:cd:76:7a:2a:e8:cd:bc:4d:0d:a4:
                    e3:6a:6e:19:56:41:e6:f4:82:c7:26:4e:66:d2:d7:
                    3f:5a:83:e2:b2:5a:25:e2:e3:52:eb:b3:04:d9:64:
                    d2:18:61:38:8b:c3:0c:83:19:34:78:cc:32:89:d7:
                    33:c1:d0:da:17:6b:a4:a0:67:14:84:4a:c0:93:0b:
                    af:49:d6:cc:ec:dc:11:a6:af:f8:44:24:5a:0f:66:
                    b0:db:48:c1:94:80:92:98:e6:fb:b7:aa:fb:f4:73:
                    f8:85:b2:e6:c5:f8:41:ce:e1:64:6b:b5:d4:1e:a3:
                    4b:16:e9:54:47:3f:1b:67:20:a6:06:b6:ee:9f:9a:
                    ec:46:36:2e:c7:a6:3e:b8:8f:a3:d7:01:d4:d7:f5:
                    ce:8f:6c:db:99:0b:16:78:a2:6c:44:48:c3:18:ed:
                    4b:21:cd:08:f2:08:ec:24:9e:f4:8d:9e:89:dd:cf:
                    e3:78:c8:1d:14:07:5a:5c:7d:c2:8d:b2:76:b2:ba:
                    91:df:87:ca:f6:a1:f4:e6:f6:44:f2:a8:0e:f1:6e:
                    e7:cf:14:ce:77:bb:2d:e3:56:0b:f1:98:a3:19:5a:
                    76:e0:00:65:0b:cc:f9:0b:56:86:b3:cc:33:1e:a1:
                    f2:23:45:8e:a7:2d:fa:d2:be:6f:bc:1a:57:08:b5:
                    ee:f9:9e:e9:e0:47:7c:31:fe:42:f4:77:41:4f:8c:
                    b2:6f:0c:c5:25:ba:3c:29:ba:4b:55:18:34:a7:00:
                    a3:7f:c5:15:94:5b:90:7d:21:cd:79:a2:a0:87:e5:
                    d2:88:e7:e4:0d:0d:db:bf:76:6d:68:7a:2b:35:61:
                    e5:72:ec:0f:81:3c:7b:b4:8e:e1:cf:38:a0:37:fe:
                    94:9d:e2:30:81:25:6b:f6:1b:47:7f:6c:6b:70:85:
                    a0:cc:99:f0:70:05:14:22:f7:6b:25:b4:4b:62:90:
                    0f:47:7c:75:cf:ee:4e:71:b9:e8:35:43:ce:bb:31:
                    29:47:63:e4:0c:97:28:22:44:36:a1:8b:36:76:ca:
                    2a:d0:f4:05:1d:43:3f:42:54:c1:58:17:d1:b1:9d:
                    1e:9d:1e:99:80:b8:aa:81:36:da:76:03:52:57:f8:
                    fe:fd:52:12:32:95:85:81:f0:ae:fc:04:c9:39:9f:
                    fc:40:fa:09:de:9c:d2:2d:b0:f6:f3:04:81:08:fc:
                    11:e3:3b:b3:65:98:9a:55:57:c3:5f:62:6d:e9:b0:
                    71:3c:23:a0:27:c2:e8:56:8c:e8:e0:53:ce:33:4b:
                    62:9e:df
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                4D:4E:99:3C:ED:A9:C0:58:01:ED:07:6F:90:FD:78:FF:D4:95:2A:03
            X509v3 Authority Key Identifier:
                4D:4E:99:3C:ED:A9:C0:58:01:ED:07:6F:90:FD:78:FF:D4:95:2A:03
            X509v3 Basic Constraints: critical
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        bd:77:5a:59:8e:9e:b3:24:e9:34:58:b3:9d:d6:67:9b:a4:af:
        d9:5a:d6:32:7e:9d:14:f8:44:58:9a:2a:cf:13:8b:f6:cc:1e:
        f8:24:e2:2a:e3:d5:76:4f:a9:0d:83:e7:a9:18:97:42:3a:6d:
        5a:33:74:7f:1d:b7:61:2f:86:ad:73:fe:ca:23:cb:ea:17:74:
        ed:ed:f9:b3:06:18:d9:c1:2e:0d:cd:b4:98:aa:0b:1b:6d:19:
        fa:a3:d6:a6:49:88:4d:ce:b6:11:f6:20:c7:4c:0a:99:a2:ce:
        70:13:a3:dd:66:58:d4:45:cb:01:89:24:bb:69:25:d9:18:c8:
        23:d1:5f:c7:98:07:73:2e:7a:2b:bc:b1:8d:b7:b4:c0:63:58:
        2f:8f:ea:f5:5c:be:d8:64:7a:ce:d3:15:f6:dc:f5:26:fe:b2:
        3e:95:db:ac:03:1f:ee:4f:e0:71:95:7d:74:75:04:45:b9:7e:
        cf:30:ec:38:31:8c:08:4c:ea:6b:e6:c5:52:25:c2:f5:b7:49:
        72:09:dd:bf:14:14:cc:8e:dd:18:c8:f6:c9:8f:3c:f2:96:44:
        6a:e3:b6:7f:42:be:70:10:39:14:a4:ac:dc:53:e3:fb:fe:d3:
        4a:44:8a:c6:2e:5f:bd:83:38:f5:c6:29:89:0f:0e:67:69:30:
        3b:2f:3e:3c:06:78:8d:86:59:35:a9:d4:67:89:74:e9:47:83:
        53:ab:73:a5:95:49:87:79:68:8e:36:88:14:a0:d5:20:02:8e:
        ad:89:ee:f1:ab:d1:4f:a1:e3:d7:35:16:a0:31:6f:e7:2e:e1:
        43:83:6b:d8:17:54:81:1d:1a:ac:1a:c5:67:1c:e3:9c:c7:12:
        79:af:30:3e:4c:43:07:7c:59:56:21:ff:99:16:57:ee:d4:38:
        2c:52:77:fb:a9:7b:9a:2b:ae:da:88:7b:a2:4b:a7:ac:5c:2b:
        d8:4f:d3:ab:20:b5:00:b8:66:e0:b2:91:8e:cc:80:5c:3f:4c:
        84:40:e0:76:da:4f:72:ce:a1:83:b2:c4:a4:d2:31:40:dd:e9:
        b2:d3:88:3d:17:5b:fb:f8:74:e9:8e:4b:ee:30:d4:02:67:0d:
        db:d9:1a:25:63:38:ec:2b:fa:a4:0c:38:1e:77:33:b1:3c:97:
        7d:e9:5a:cd:9a:ef:eb:56:a5:c8:9c:5e:43:63:71:09:fe:a2:
        81:a0:e0:68:c4:3b:65:25:be:33:52:23:17:73:d6:4a:34:9d:
        ac:37:eb:0d:a1:4e:4a:67:51:6e:8b:61:3f:a5:ef:5e:08:a1:
        77:d8:1c:36:f1:c1:84:7e:f4:d2:17:18:93:55:40:0f:8a:76:
        23:38:d6:e7:32:d3:46:dd
```

```bash
C:\Users\Administrator>curl -I http://g07-blame.internal
HTTP/1.1 301 Moved Permanently
Date: Tue, 23 Apr 2024 12:34:36 GMT
Content-Type: text/html
Content-Length: 162
Connection: keep-alive
Location: https://g07-blame.internal/
```

```bash
[vagrant@rp ~]$ curl https://192.168.107.150
curl: (7) Failed to connect to 192.168.107.150 port 443: No route to host
```

```bash
[vagrant@rp ~]$ curl -I http://192.168.107.150
HTTP/1.1 200 OK
Date: Tue, 23 Apr 2024 12:36:48 GMT
Server: Apache
Last-Modified: Tue, 23 Apr 2024 11:58:20 GMT
ETag: "4b0-616c2452dea91"
Accept-Ranges: bytes
Content-Length: 1200
Content-Type: text/html; charset=UTF-8
```

```bash
[vagrant@rp ~]$ curl http://192.168.107.150
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SleepingDragon</title>
    <link rel="stylesheet" href="css/style.css" />
  </head>
  <body>
    <div>
      <h2>SleepingDragon</h2>
      <p>
        You find yourself in a cave, and in this cave, you see only one thing! A
        DRAGON! Luckily, it's asleep. You could leave it alone, but you're a bit
        of a pest and can't resist poking it a few times!
      </p>
      <p>
        You convince yourself that if you can poke the dragon 5 times, you will
        feel successful in your life! And I don't need to explain why this is
        something you want, do I?!
      </p>
      <button id="buttonStartSpel">Start Game</button>
    </div>

    <p id="text">Would you like to poke the dragon? It's very tempting.</p>
    <div id="choice">
      <button id="yes">Yes</button>
      <button id="no">No</button>
    </div>
    <p id="winStreak">Your current winning streak: 0</p>
    <script src="js/app.js"></script>
  </body>
</html>
```

```bash
[vagrant@rp ~]$ curl -I --insecure --http2-prior-knowledge https://192.168.107.164
HTTP/2 200 
date: Tue, 23 Apr 2024 12:38:35 GMT
content-type: text/html; charset=UTF-8
content-length: 1200
last-modified: Tue, 23 Apr 2024 11:58:20 GMT
etag: "4b0-616c2452dea91"
accept-ranges: bytes
```

Test geslaagd:

- [x] Ja
- [ ] Nee


## Test: Uitbreiding: Als de webserver gescand wordt met nmap, geeft deze geen informatie over de versie van de webserver EN geen http header info

Verkregen resultaat:

```bash
[vagrant@rp ~]$ nmap 192.168.107.164
Starting Nmap 7.92 ( https://nmap.org ) at 2024-04-23 12:41 UTC
Nmap scan report for g07-blame.internal (192.168.107.164)
Host is up (0.00025s latency).
Not shown: 995 closed tcp ports (conn-refused)
PORT     STATE SERVICE
22/tcp   open  ssh
80/tcp   open  http
111/tcp  open  rpcbind
443/tcp  open  https
9090/tcp open  zeus-admin

Nmap done: 1 IP address (1 host up) scanned in 0.10 seconds
```

```bash
[vagrant@rp ~]$ curl -I --insecure https://192.168.107.164
HTTP/2 200 
date: Tue, 23 Apr 2024 12:42:13 GMT
content-type: text/html; charset=UTF-8
content-length: 1200
last-modified: Tue, 23 Apr 2024 11:58:20 GMT
etag: "4b0-616c2452dea91"
accept-ranges: bytes
```

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen: /