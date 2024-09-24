# Testrapport: Nat Portforwarding/ACL's


- Auteur(s) respectievelijke testplan: Bert Coudenys
- Uitvoerder(s) test: Matteo Alexander
- Uitgevoerd op: 14/05/2024



## Test: Nat Portforwarding

Test procedure:

- Configuratie

    1. Controleer dat beide routers nat portforwarding settings bevatten.

    2. Zorg ervoor dat het inkomende verkeer naar ip adres 172.22.200.7 op poorten 80 & 443 worden doorgestuurd naar de interne proxy.
```bash
    ip forward-protocol nd
no ip http server
ip http authentication local
no ip http secure-server
ip tftp source-interface GigabitEthernet0
ip nat inside source static tcp 192.168.107.164 80 172.22.200.7 80 extendable
ip nat inside source static tcp 192.168.107.164 443 172.22.200.7 443 extendable
ip nat inside source list PUBLICIP interface GigabitEthernet0/0/0 overload
ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0/0
!
!
ip access-list standard PUBLICIP
 permit 192.168.107.0 0.0.0.255
 deny   any
```
- Testen werking

    1. Voer een externe test uit door vanuit een ander device vanop het publiek netwerk te surfen naar ons domain: https://nextcloud.g07-blame.internal/
     ![Image website](img/testrapsite.png)

Test geslaagd:

- [x] ja
- [ ] nee

## Test: ACL's

- Configuratie:
    
    1. Zorg dat de ACL's als volgt zijn ingesteld
```bash
ip access-list extended NO-ACCESS-MANAGEMENT
 permit ip 192.168.107.128 0.0.0.15 any
 deny ip any any
!
ip access-list extended NO-ACCESS-INTERNAL-SERVER
 permit udp any any
 permit tcp any any established
 permit ip 192.168.107.0 0.0.0.127 any
 permit ip 192.168.107.160 0.0.0.7 any
 permit ip 192.168.107.144 0.0.0.15 any
 deny ip any any
!
ip access-list extended NO-ACCESS-INTERNAL-CLIENTS
 permit ip 192.168.107.0 0.0.0.127 any
 permit ip 192.168.107.160 0.0.0.7 any
 permit ip 192.168.107.144 0.0.0.15 any
 permit tcp any any established
 deny ip any any
!
!
ip access-list extended NO-ACCESS-PROXY
 permit ip 192.168.107.150 0.0.0.0 host 192.168.107.164
 permit tcp any any established
 permit tcp any any eq 443
 permit tcp any any eq www
 deny   ip any any
!
!
!
!
!
ipv6 access-list NO-ACCESS-MANAGEMENT-IPV6
 permit ipv6 2001:DB8:AC07:1::/64 any
!
ipv6 access-list NO-ACCESS-PROXY-IPV6
 permit ipv6 host 2001:db8:ac07:42::6 host 2001:db8:ac07:13::4
 permit tcp any any established
 permit tcp any any eq www
 permit tcp any any eq 443
!
ipv6 access-list NO-ACCESS-INTERNAL-SERVER-IPV6
 permit udp any any
 permit tcp any any established
 permit ipv6 2001:DB8:AC07:11::/64 any
 permit ipv6 2001:DB8:AC07:13::/64 any
 permit ipv6 2001:DB8:AC07:42::/64 any
!
ipv6 access-list NO-ACCESS-INTERNAL-CLIENTS-IPV6
 permit ipv6 2001:DB8:AC07:11::/64 any
 permit ipv6 2001:DB8:AC07:13::/64 any
 permit ipv6 2001:DB8:AC07:42::/64 any
 permit tcp any any established
```

- Testen werking
  
    1. Ping vanop de client de proxy server
```bash
C:\>ping 192.168.137.164

Pinging 192.168.137.164 with 32 bytes of data:

Reply from 192.168.107.2: Destination host unreachable.
Reply from 192.168.107.2: Destination host unreachable.
Reply from 192.168.107.2: Destination host unreachable.
Request timed out.

Ping statistics for 192.168.137.164:
    Packets: Sent = 4, Received = 0, Lost = 4 (100% loss),
```
   2. Ping de Client vanaf de ISP router
```bash
ISP>en
ISP#ping 192.168.107.4

Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.107.4, timeout is 2 seconds:
.UUUU
Success rate is 0 percent (0/5)
```

   3. De belangrijke connecties zouden wel nog moeten werken. Probeer de wordpress site te openen op de client
   ![Image website](img/testrapsite.png)

Test geslaagd:

- [x] ja
- [ ] nee