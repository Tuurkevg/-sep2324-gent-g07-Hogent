# Testrapport: Nat Portforwarding/ACL's


- Auteur(s) respectievelijke testplan: Bert Coudenys/Matteo Alexander
- Uitvoerder(s) test: Emiel Lauwers
- Uitgevoerd op: 14/05/2024


## Test: Netwerk ipv6

Test procedure:

- Testen

    1. Test ipv6 door te pingen van de client naar de server
```bash
    C:\>ping 2001:DB8:AC07:42::5

Pinging 2001:DB8:AC07:42::5 with 32 bytes of data:

Reply from 2001:DB8:AC07:42::5: bytes=32 time<1ms TTL=127
Reply from 2001:DB8:AC07:42::5: bytes=32 time<1ms TTL=127
Reply from 2001:DB8:AC07:42::5: bytes=32 time<1ms TTL=127
Reply from 2001:DB8:AC07:42::5: bytes=32 time=6ms TTL=127

Ping statistics for 2001:DB8:AC07:42::5:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 6ms, Average = 1ms
```

Test geslaagd:

- [x] ja
- [ ] nee
  
## Test: Windows ipv6

- Configuratie
  
    1. Zorg dat de client zijn ipv6 enabled is en staat op dhcp
    2. Start de Windows Server op

- Testen
    1. Vraag op de client een nieuw ip adres aan de Winserver
```bash
C:\Users\Administrator>ipconfig /renew

Windows IP Configuration


Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . : g07-blame.internal
   IPv6 Address. . . . . . . . . . . : 2001:db8:ac07:0:485b:262b:bdba:7bbf
   Temporary IPv6 Address. . . . . . : 2001:db8:ac07:0:4d2d:a240:9389:971c
   Link-local IPv6 Address . . . . . : fe80::485b:262b:bdba:7bbf%6
   IPv4 Address. . . . . . . . . . . : 192.168.107.10
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.107.1

C:\Users\Administrator>
```
   2. Ping het ipv6 van de client vanop de Winserver
```bash
PS C:\Users\Administrator> ping 2001:db8:ac07:0:485b:262b:bdba:7bbf 

Pinging 2001:db8:ac07:0:485b:262b:bdba:7bbf with 32 bytes of data: 
Reply from 2001:db8:ac07:0:485b:262b:bdba:7bbf: time<1ms
Reply from 2001:db8:ac07:0:485b:262b:bdba:7bbf: time<1ms
Reply from 2001:db8:ac07:0:485b:262b:bdba:7bbf: time<1ms
Reply from 2001:db8:ac07:0:485b:262b:bdba:7bbf: time<1ms

Ping statistics for 2001:db8:ac07:0:485b:262b:bdba:7bbf: 
	Packets: Sent = 4, Received = 4, Lost = 0 (0 % loss), 
Approximate round trip times in milli-seconds: 
	Minimum = 0ms , Maximum = 0ms, Average = 0ms
```
   3. ping de wordpress site met ipv6 vanop de client
```bash
C:\Users\Administrator.G07-BLAME> ping -6 g07 - blame.internal 

Pinging g07-blame.internal [2001:db8:ac07:13::4] with 32 bytes of data: 
Reply from 2001:db8:ac07:13::4: time = 1ms 
Reply from 2001:db8:ac07:13::4: time = 1ms 
Reply from 2001:db8:ac07:13::4: time = 1ms 
Reply from 2001:db8:ac07:13::4: time = 1ms 

Ping statistics for 2001:db8:ac07:13::4: 
   Packets: Sent = 4, Received = 4 , Lost = 0 ( 0 % loss ), 
Approximate round trip times in milli-seconds: 
   Minimum = Oms , Maximum = 1ms , Average = Oms
```
Test geslaagd:

- [x] ja
- [ ] nee