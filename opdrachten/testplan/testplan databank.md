# Testplan: Linux databank

- Auteur(s) testplan: Matteo Alexander

**Opgelet**: de output kan verschillen in een echte opstelling, het gegeven "Verwacht resultaat" voor een test is slechts een placeholder voor een mogelijk geldige output. Het apparaat waar de test op wordt uitgevoerd, staat telkens tussen haakjes in de titel van elke test/stap.

1) Ga naar de juiste directory *(Hostmachine databank-VM)*

```
C:\Users\matte\OneDrive\Documenten\HOgent\SEP\sep2324-gent-g07> cd .\opdrachten\Linux\Vagrant-VirtualeMachine\
```

2) Start de databank vm op *(Hostmachine databank-VM)*

```
C:\Users\matte\OneDrive\Documenten\HOgent\SEP\sep2324-gent-g07\opdrachten\Linux\Vagrant-VirtualeMachine> vagrant up db
```

3) Log in op de vm *(Hostmachine databank-VM)*

```
C:\Users\matte\OneDrive\Documenten\HOgent\SEP\sep2324-gent-g07\opdrachten\Linux\Vagrant-VirtualeMachine> vagrant ssh db
```

4) Check of SELinux actief is *(Databank-VM)*

```
[vagrant@db ~]$ getenforce
Enforcing
```

5) Bekijk de netwerkinstellingen *(Databank-VM)*

```
[vagrant@db ~]$ ip a
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
       valid_lft 80803sec preferred_lft 80803sec
    inet6 fe80::f955:42a7:b029:b7ce/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:04:5c:7c brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.1.8/24 brd 192.168.1.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe04:5c7c/64 scope link
       valid_lft forever preferred_lft forever
```

Zorg dat het ip address van eth1 overeenkomt met het static ip adres in common.sh voor STATIC_IP_DB

6) Test of je de webserver kan pingen *(Databank-VM)*

```
[vagrant@db ~]$ ping 192.168.1.7
PING 192.168.1.7 (192.168.1.7) 56(84) bytes of data.
64 bytes from 192.168.1.7: icmp_seq=1 ttl=64 time=0.324 ms
64 bytes from 192.168.1.7: icmp_seq=2 ttl=64 time=0.290 ms
64 bytes from 192.168.1.7: icmp_seq=3 ttl=64 time=0.265 ms
64 bytes from 192.168.1.7: icmp_seq=4 ttl=64 time=0.305 ms
^C
--- 192.168.1.7 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3110ms
rtt min/avg/max/mdev = 0.265/0.296/0.324/0.021 ms
```

7) Check of de Mariadb service actief is *(Databank-VM)*

```
[vagrant@db ~]$ sudo systemctl status mariadb
```

8) Controleer of de MariaDB-service luistert op het juiste IP-adres

```
[vagrant@db ~]$ sudo netstat -tuln | grep 3306
tcp        0      0 192.168.1.8:3306        0.0.0.0:*               LISTEN
```

9) Bekijk de firwall instellingen *(Databank-VM)*

```
[vagrant@db ~]$ sudo firewall-cmd  --list-all   
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0
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
        rule family="ipv4" source address="192.168.1.7" port port="3306" protocol="tcp" accept
```

Zorg dat bij de rich rules het source address is ingesteld op het ip adres van de webserver.
Hierdoor heeft de web vm toegang tot de MariaDb.

10) Controleer of de root-wachtwoord voor MariaDB is ingesteld *(Databank-VM)*

```
[vagrant@db ~]$ sudo mysqladmin -u root -p status
Enter password:
Uptime: 8449  Threads: 1  Questions: 1098  Slow queries: 0  Opens: 33  Open tables: 26  Queries per second avg: 0.129
```
11) Controleer of alleen SSH-key authenticatie is ingeschakeld en root-login via SSH is uitgeschakeld
```
[vagrant@db ~]$ sudo grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
```

12) Probeer de Mariadb te gebruiken *(Databank-VM)*

```
[vagrant@db ~]$ sudo mysql
```

13) Bekijk de databanken *(Databank-VM)*

```
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| wordpress_db       |
+--------------------+
4 rows in set (0.006 sec)
```