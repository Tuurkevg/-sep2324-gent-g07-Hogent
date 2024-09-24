# Testplan: Linux TFTP-server

- Auteur(s) testplan: Lucas Ludueña-Segre

**Opgelet**: de output kan verschillen in een echte opstelling, het gegeven "Verwacht resultaat" voor een test is slechts een placeholder voor een mogelijk geldige output. Het apparaat waar de test op wordt uitgevoerd, staat telkens tussen haakjes in de titel van elke test/stap.

## Test: Algemene checks

Testprocedure:

1. Start de TFTP-server op via Vagrant. *(Hostmachine TFTP-VM)*
2. Log in via SSH. *(Hostmachine TFTP-VM)*
3. Verifiëer dat SELinux actief is. *(TFTP-VM)*
4. Verifiëer de netwerkinstellingen. *(TFTP-VM)*
5. Controleer dat de server kan pingen naar een netwerkapparaat (router of switch) *(TFTP-VM)*


Verwacht resultaat:

1. De opstart van de TFTP-server verloopt foutloos.

```
>vagrant up tftp
Bringing machine 'tftp' up with 'virtualbox' provider...
==> tftp: Importing base box 'bento/almalinux-9'...
==> tftp: Matching MAC address for NAT networking...
==> tftp: Checking if box 'bento/almalinux-9' version '202309.08.0' is up to date...
==> tftp: Setting the name of the VM: Vagrant-VirtualeMachine_tftp_1711448943638_82308
==> tftp: Fixed port collision for 22 => 2222. Now on port 2200.
==> tftp: Clearing any previously set network interfaces...
...
```
- ...

2. Er wordt via SSH ingelogd via SSH keys, niet met een (root-)wachtwoord.

```
>vagrant ssh tftp  

This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
[vagrant@tftp ~]$ 
```

3. SELinux staat op actief.

```
[vagrant@tftp ~]$ getenforce
Enforcing
```

4. Het IP adres van `eth1` komt overeen met het statische IP-adres `STATIC_IP_WEB` in het algemene provisioningscript `common.sh`.

```
[vagrant@tftp ~]$ ip a
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
       valid_lft 84856sec preferred_lft 84856sec
    inet6 fe80::4ea3:1318:85fc:184f/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:97:4b:08 brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.107.133/28 brd 192.168.107.143 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe97:4b08/64 scope link 
       valid_lft forever preferred_lft forever
```

5. De ping naar het netwerkapparaat (in dit geval de switch) verloopt foutloos.

```
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

## Test: De TFTP-server is geïnstalleeerd.

Testprocedure:

1. Controleer of de TFTP-server draait. *(TFTP-VM)*
2. Controleer de firewall-instellingen. *(TFTP-VM)*

Verwacht resultaat:

1. De TFTP-server draait foutloos.

```
[vagrant@tftp ~]$ systemctl status tftp
WARNING: terminal is not fully functional
Press RETURN to continue 
○ tftp.service - Tftp Server
     Loaded: loaded (/usr/lib/systemd/system/tftp.service; enabled; preset: disabled)
     Active: inactive (dead) since Tue 2024-03-26 10:41:36 UTC; 21min ago
   Duration: 15min 76ms
TriggeredBy: ● tftp.socket
       Docs: man:in.tftpd
    Process: 8594 ExecStart=/usr/sbin/in.tftpd -c -p -s /etc/tft/sharedfolder -v -u tftpuser (>
   Main PID: 8594 (code=exited, status=0/SUCCESS)
        CPU: 1ms
```

2. De firewall-instellingen komen overeen met de instellingen in het provisioningscript `tftp.sh`.

```
[vagrant@tftp ~]$ sudo firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources: 
  services: cockpit dhcpv6-client ssh
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
	rule family="ipv4" source address="192.168.107.128/255.255.255.240" service name="tftp" accept
```
## Test: Netwerktoestellen worden via deze TFTP-server geconfigureerd.


Testprocedure:

1. Vanuit een netwerkapparaat (switch of router), ping naar de TFTP-server. *(S1)*
2. Kopiëer het overeenkomende configuratiebestand van de TFTP-server naar het netwerkapparaat. *(S1)*
3. Verifiïeer dat de huidige running-config op het netwerkapparaat overeenkomt met het gekopiëerde configuratiebestand. *(S1)*

Verwacht resultaat:

1. De ping zou moeten slagen:

```
S1#ping 192.168.107.133

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.107.133, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 0/0/0 ms

S1#
```

2. Het configuratiebestand wordt foutloos gekopiëerd van de TFTP-server naar het netwerkapparaat.

```
S1#copy ftp: running-config
Address or name of remote host [192.168.107.133]? 
Source filename [S1]? 
Destination filename [running-config]? 
Accessing ftp://192.168.107.133/S1...
Loading S1 !
[OK - 1030/4096 bytes]
1030 bytes copied in 13.213 secs (78 bytes/sec)
```

3. De huidige running-config op het netwerkapparaat komt overeen met het gekopiëerde configuratiebestand.

```
S1#show running-config 
Building configuration...

Current configuration : 2573 bytes
!
version 15.0
no service pad
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname S1
!
boot-start-marker
boot-end-marker
!
!
no aaa new-model
system mtu routing 1500
!
!
!
!
!
!
!
!
!
!
spanning-tree mode pvst
spanning-tree extend system-id
!
vlan internal allocation policy ascending
!
!
!
!
!
!
interface FastEthernet0/1
 switchport access vlan 42
 switchport mode access
!
interface FastEthernet0/2
 switchport access vlan 42
 switchport mode access
!
interface FastEthernet0/3
 switchport access vlan 42
 switchport mode access
!
interface FastEthernet0/4
 switchport access vlan 42
 switchport mode access
!
interface FastEthernet0/5
 switchport access vlan 42
 switchport mode access
!
interface FastEthernet0/6
 switchport access vlan 42
 switchport mode access
--More--
```