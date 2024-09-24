#### Configuratie Interface g0/0

ISP(config)#int g0/0
ISP(config-if)#ip address 192.168.107.254 255.255.255.248
ISP(config-if)#ipv6 address 2001:db8:ac07:150::10/64

ISP(config)#ip route 192.168.107.0 255.255.255.0 g0/0
ISP(config)#ipv6 route 2001:db8:ac07::/48 g0/0

#### Extra

ISP#copy running-config startup-config
