# Testrapport: Linux TFTP-server

- Auteur(s) testrapport: Matteo Alexander

## Test: Algemene checks

Testprocedure:

1. Start de TFTP-server op via Vagrant.
2. Log in via SSH.
3. Verifiëer dat SELinux actief is.
4. Verifiëer de netwerkinstellingen.
5. Controleer dat de server kan pingen naar een netwerkapparaat (router of switch)

Verkregen resultaat:

- De opstart van de TFTP-server verloopt foutloos.
- Er wordt via SSH ingelogd via SSH keys, niet met een (root-)wachtwoord.
- SELinux staat op actief.
- Het IP adres van eth1 komt overeen met het statische IP-adres STATIC_IP_TFTP in het algemene provisioningscript common.sh.
- De ping naar het netwerkapparaat (in dit geval de switch) verloopt foutloos.

```bash
[vagrant@tftp ~]$ ping 192.168.107.132
PING 192.168.107.132 (192.168.107.132) 56(84) bytes of data.
64 bytes from 192.168.107.132: icmp_seq=1 ttl=63 time=0.286 ms
64 bytes from 192.168.107.132: icmp_seq=2 ttl=63 time=0.615 ms
64 bytes from 192.168.107.132: icmp_seq=3 ttl=63 time=0.589 ms
64 bytes from 192.168.107.132: icmp_seq=4 ttl=63 time=0.174 ms
^C
--- 192.168.107.132 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3169ms
rtt min/avg/max/mdev = 0.174/0.416/0.615/0.190 ms
```

Test geslaagd:

- [x] Ja
- [ ] Nee


## Test: De TFTP-server is geïnstalleeerd.

Testprocedure:

1. Controleer of de TFTP-server draait.
2. Controleer de firewall-instellingen.

Verkregen resultaat:

- De ping van het netwerkapparaat naar de TFTP-server zou moeten slagen

```bash
S1#ping 192.168.107.133

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.107.133, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/0/0 ms

S1#
```

- Het configuratiebestand wordt foutloos gekopiëerd van de TFTP-server naar het netwerkapparaat.

```bash
S1#copy ftp: running-config
Address or name of remote host [192.168.107.133]? 
Source filename [S1]? 
Destination filename [running-config]? 
Accessing ftp://192.168.107.133/S1...
Loading S1 !
[OK - 1030/4096 bytes]
1030 bytes copied in 13.213 secs (78 bytes/sec)
```

- De huidige running-config op het netwerkapparaat komt overeen met het gekopiëerde configuratiebestand.

Test geslaagd:

- [x] Ja
- [ ] Nee


Opmerkingen: /