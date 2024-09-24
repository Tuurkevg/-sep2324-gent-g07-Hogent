# Testrapport: Linux databank

- Auteur(s) respectievelijke testplan: Matteo Alexander
- Uitvoerder(s) test: Lucas Ludueña-Segre
- Uitgevoerd op: 12/05/2024

## Test: Linux databank

Test procedure:

1. Ga naar de juiste directory
2. Start de databank vm op
3. Log in op de vm
4. Check of SELinux actief is
5. Bekijk de netwerkinstellingen
6. Test of je de webserver kan pingen
7. Check of de Mariadb service actief is
8. Controleer of de MariaDB-service luistert op het juiste IP-adres
9. Bekijk de firewall instellingen
10. Controleer of de root-wachtwoord voor MariaDB is ingesteld
11. Controleer of alleen SSH-key authenticatie is ingeschakeld en root-login via SSH is uitgeschakeld
12. Probeer de Mariadb te gebruiken
13. Bekijk de databanken

Verkregen resultaat:

1. Ga naar de juiste directory

```
lucas@Findux:~$ cd sep2324-gent-g07/opdrachten/Linux/Vagrant-VirtualeMachine/
lucas@Findux:~/sep2324-gent-g07/opdrachten/Linux/Vagrant-VirtualeMachine$
```

2. Start de databank vm op

```
lucas@Findux:~/sep2324-gent-g07/opdrachten/Linux/Vagrant-VirtualeMachine$ vagrant up db
```

3. Log in op de vm

```
lucas@Findux:~/sep2324-gent-g07/opdrachten/Linux/Vagrant-VirtualeMachine$ vagrant ssh db 

This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
[vagrant@db ~]$ 
```

4. Check of SELinux actief is

```
[vagrant@db ~]$ getenforce
Enforcing
```

5. Bekijk de netwerkinstellingen

```
[vagrant@db ~]$ ip a                                                                           
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
       valid_lft 83227sec preferred_lft 83227sec
    inet6 fe80::7b72:df38:1076:96e2/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:3a:44:3e brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet 192.168.0.3/24 brd 192.168.0.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe3a:443e/64 scope link 
       valid_lft forever preferred_lft forever
```

6. Test of je de webserver kan pingen

```
[vagrant@db ~]$ ping 192.168.0.2
PING 192.168.0.2 (192.168.0.2) 56(84) bytes of data.
64 bytes from 192.168.0.2: icmp_seq=1 ttl=64 time=0.266 ms
64 bytes from 192.168.0.2: icmp_seq=2 ttl=64 time=0.662 ms
64 bytes from 192.168.0.2: icmp_seq=3 ttl=64 time=0.556 ms
64 bytes from 192.168.0.2: icmp_seq=4 ttl=64 time=0.810 ms
^C
--- 192.168.0.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3081ms
rtt min/avg/max/mdev = 0.266/0.573/0.810/0.199 ms
```

7. Check of de Mariadb service actief is

```
[vagrant@db ~]$ sudo systemctl status mariadb
WARNING: terminal is not fully functional
Press RETURN to continue 
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; preset: disabled)
     Active: active (running) since Sun 2024-05-12 21:23:41 UTC; 52min ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 8590 ExecStartPre=/usr/libexec/mariadb-check-socket (code=exited, status=0/SUCCES>
    Process: 8612 ExecStartPre=/usr/libexec/mariadb-prepare-db-dir mariadb.service (code=exite>
    Process: 8661 ExecStartPost=/usr/libexec/mariadb-check-upgrade (code=exited, status=0/SUCC>
   Main PID: 8647 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 8 (limit: 11054)
     Memory: 78.9M
        CPU: 782ms
     CGroup: /system.slice/mariadb.service
             └─8647 /usr/libexec/mariadbd --basedir=/usr

May 12 21:23:41 db systemd[1]: Starting MariaDB 10.5 database server...
May 12 21:23:41 db mariadb-prepare-db-dir[8612]: Database MariaDB is probably initialized in />
May 12 21:23:41 db mariadb-prepare-db-dir[8612]: If this is not the case, make sure the /var/l>
May 12 21:23:41 db systemd[1]: Started MariaDB 10.5 database server.
lines 1-20/20 (END)
```

8. Controleer of de MariaDB-service luistert op het juiste IP-adres

```
[vagrant@db ~]$ sudo netstat -tuln | grep 3306
tcp        0      0 192.168.0.3:3306        0.0.0.0:*               LISTEN     
```

9. Bekijk de firewall instellingen

```
[vagrant@db ~]$ sudo firewall-cmd  --list-all
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
	rule family="ipv4" source address="192.168.0.2" port port="3306" protocol="tcp" accept
```

10. Controleer of de root-wachtwoord voor MariaDB is ingesteld

```
[vagrant@db ~]$ sudo mysqladmin -u root -p status
Enter password: 
Uptime: 3348  Threads: 1  Questions: 1097  Slow queries: 0  Opens: 30  Open tables: 23  Queries per second avg: 0.327
```

11. Controleer of alleen SSH-key authenticatie is ingeschakeld en root-login via SSH is uitgeschakeld

```
[vagrant@db ~]$ sudo grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config
PermitRootLogin no
PasswordAuthentication no
# PasswordAuthentication.  Depending on your PAM configuration,
# the setting of "PermitRootLogin without-password".
# PAM authentication, then enable this but set PasswordAuthentication
```

12. Probeer de Mariadb te gebruiken

```
[vagrant@db ~]$ sudo mysql                                                                    
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 17
Server version: 10.5.22-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

No entry for terminal type "xterm-kitty";
using dumb terminal settings.
No entry for terminal type "xterm-kitty";
using dumb terminal settings.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> 
```

13. Bekijk de databanken

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
4 rows in set (0.001 sec)
```

Test geslaagd:

- [x] Ja
- [ ] Nee

Opmerkingen:

- Deze test werd uitgevoerd in een lokale omgeving buiten het serverlokaal op de campus. Hierdoor kwamen de IP-adressen niet overeen met de verwachte output, maar de werking bleef hetzelfde.
