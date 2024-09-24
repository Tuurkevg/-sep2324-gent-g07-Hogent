#### Configuratie sub interface g0/0/1.1

R1(config)#interface g0/0/1.1
R1(config-subif)#description Default gateway vlan1
R1(config-subif)#encapsulation dot1Q 1
R1(config-subif)#ip address 192.168.107.130 255.255.255.240
R1(config-subif)#ipv6 address 2001:db8:ac07:1::2/64

R1(config-subif)#ip access-group NO-ACCESS-MANAGEMENT out
R1(config-subif)#ipv6 traffic-filter NO-ACCESS-MANAGEMENT-IPV6 out

R1(config-subif)#standby version 2

R1(config-subif)#standby 1 ip 192.168.107.129
R1(config-subif)#standby 1 priority 150
R1(config-subif)#standby 1 preempt

R1(config-subif)#standby 2 ipv6 2001:DB8:AC07:1::1/64
R1(config-subif)#standby 2 priority 150
R1(config-subif)#standby 2 preempt

R1(config-subif)#ip nat inside

#### Configuratie sub interface g0/0/1.11

R1(config)#interface g0/0/1.11
R1(config-subif)#description Default gateway vlan11
R1(config-subif)#encapsulation dot1Q 11
R1(config-subif)#ip address 192.168.107.2 255.255.255.128
R1(config-subif)#ipv6 address 2001:db8:ac07:11::2/64
R1(config-subif)#ip helper-address 192.168.107.148

R1(config-subif)#ip access-group NO-ACCESS-INTERNAL-CLIENTS out
R1(config-subif)#ipv6 traffic-filter NO-ACCESS-INTERNAL-CLIENTS-IPV6 out

R1(config-subif)#standby version 2

R1(config-subif)#standby 1 ip 192.168.107.1
R1(config-subif)#standby 1 priority 150
R1(config-subif)#standby 1 preempt

R1(config-subif)#standby 2 ipv6 2001:DB8:AC07:11::1/64
R1(config-subif)#standby 2 priority 150
R1(config-subif)#standby 2 preempt

R1(config-subif)#ip nat inside

#### Configuratie sub interface g0/0/1.13

R1(config)#interface g0/0/1.13
R1(config-subif)#description Default gateway vlan13
R1(config-subif)#encapsulation dot1Q 13
R1(config-subif)#ip address 192.168.107.162 255.255.255.248
R1(config-subif)#ipv6 address 2001:db8:ac07:13::2/64

R1(config-subif)#ip access-group NO-ACCESS-PROXY out
R1(config-subif)#ipv6 traffic-filter NO-ACCESS-PROXY-IPV6 out

R1(config-subif)#standby version 2

R1(config-subif)#standby 1 ip 192.168.107.161
R1(config-subif)#standby 1 priority 150
R1(config-subif)#standby 1 preempt

R1(config-subif)#standby 2 ipv6 2001:DB8:AC07:13::1/64
R1(config-subif)#standby 2 priority 150
R1(config-subif)#standby 2 preempt

R1(config-subif)#ip nat inside

#### Configuratie sub interface g0/0/1.42

R1(config)#interface g0/0/1.42
R1(config-subif)#description Default gateway vlan42
R1(config-subif)#encapsulation dot1Q 42
R1(config-subif)#ip address 192.168.107.146 255.255.255.240
R1(config-subif)#ipv6 address 2001:db8:ac07:42::2/64

R1(config-subif)#ip access-group NO-ACCESS-INTERNAL-SERVER out
R1(config-subif)#ipv6 traffic-filter NO-ACCESS-INTERNAL-SERVER-IPV6 out

R1(config-subif)#standby version 2

R1(config-subif)#standby 1 ip 192.168.107.145
R1(config-subif)#standby 1 priority 150
R1(config-subif)#standby 1 preempt

R1(config-subif)#standby 2 ipv6 2001:DB8:AC07:42::1/64
R1(config-subif)#standby 2 priority 150
R1(config-subif)#standby 2 preempt

R1(config-subif)#ip nat inside

#### Configuratie interface g0/0/1

R1(config-if)#no shut

#### Configuratie interface g0/0/0

R1(config)#interface g0/0/0
R1(config-if)#description Connection to ISP switch
R1(config-if)#ip address 172.22.200.107 255.255.0.0

R1(config-if)#standby version 2
R1(config-if)#standby 207 ip 172.22.200.7
R1(config-if)#standby 207 priority 150
R1(config-if)#standby 207 preempt

R1(config-if)#ip nat outside

R1(config-if)#no shut

### ACL

#### PUBLICIP

R1(config)#ip access-list standard PUBLICIP
R1(config-std-nacl)#permit 192.168.107.0 0.0.0.255
R1(config-std-nacl)#deny any

#### NO-ACCESS-MANAGEMENT

R1(config)#ip access-list extended NO-ACCESS-MANAGEMENT
R1(config-std-nacl)#permit ip 192.168.107.128 0.0.0.15 any
R1(config-std-nacl)#deny ip any any

#### NO-ACCESS-INTERNAL-SERVER

R1(config)#ip access-list extended NO-ACCESS-INTERNAL-SERVER
R1(config-std-nacl)#permit udp any any established
R1(config-std-nacl)#permit tcp any any established
R1(config-std-nacl)#permit ip 192.168.107.0 0.0.0.127 any
R1(config-std-nacl)#permit ip 192.168.107.160 0.0.0.7 any
R1(config-std-nacl)#permit ip 192.168.107.144 0.0.0.15 any
R1(config-std-nacl)#deny ip any any

#### NO-ACCESS-INTERNAL-CLIENTS

R1(config)#ip access-list extended NO-ACCESS-INTERNAL-CLIENTS
R1(config-ext-nacl)#permit ip 192.168.107.0 0.0.0.127 any
R1(config-ext-nacl)#permit ip 192.168.107.160 0.0.0.7 any
R1(config-ext-nacl)#permit ip 192.168.107.144 0.0.0.15 any
R1(config-ext-nacl)#permit tcp any any established
R1(config-ext-nacl)#deny ip any any

#### NO-ACCESS-PROXY

R1(config)#ip access-list extended NO-ACCESS-PROXY
R1(config-ext-nacl)#permit ip 192.168.107.150 0.0.0.0 host 192.168.107.164
R1(config-ext-nacl)#permit tcp any any established
R1(config-ext-nacl)#permit tcp any any eq 443
R1(config-ext-nacl)#permit tcp any any eq 80
R1(config-ext-nacl)#deny ip any any

#### NO-ACCESS-MANAGEMENT-IPV6

R1(config)#ipv6 access-list NO-ACCESS-MANAGEMENT-IPV6
R1(config-ipv6-acl)#permit ipv6 2001:db8:ac07:1::/64 any

#### NO-ACCESS-INTERNAL-SERVER-IPV6

R1(config)#ipv6 access-list NO-ACCESS-INTERNAL-SERVER-IPV6
R1(config-ipv6-acl)#permit udp any any established
R1(config-ipv6-acl)#permit tcp any any established
R1(config-ipv6-acl)#permit ipv6 2001:db8:ac07:11::/64 any
R1(config-ipv6-acl)#permit ipv6 2001:db8:ac07:13::/64 any
R1(config-ipv6-acl)#permit ipv6 2001:db8:ac07:42::/64 any

#### NO-ACCESS-INTERNAL-CLIENTS-IPV6

R1(config)#ipv6 access-list NO-ACCESS-INTERNAL-CLIENTS-IPV6
R1(config-ipv6-acl)#permit ipv6 2001:db8:ac07:11::/64 any
R1(config-ipv6-acl)#permit ipv6 2001:db8:ac07:13::/64 any
R1(config-ipv6-acl)#permit ipv6 2001:db8:ac07:42::/64 any
R1(config-ipv6-acl)#permit tcp any any established

#### NO-ACCESS-PROXY-IPV6

R1(config)#ipv6 access-list NO-ACCESS-PROXY-IPV6
R1(config)#permit ipv6 host 2001:db8:ac07:42::6 host 2001:db8:ac07:13::4
R1(config)#permit tcp any any established
R1(config-ext-nacl)#permit tcp any any eq 80
R1(config-ext-nacl)#permit tcp any any eq 443

#### Extra

R1(config)#hostname R1
R1(config)#ipv6 unicast-routing
R1(config)#ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0/0
R1(config)#no ip http server
R1(config)#no ip http secure-server
R1(config)#ip nat inside source static tcp 192.168.107.164 80 172.22.200.7 80 extendable
R1(config)#ip nat inside source static tcp 192.168.107.164 443 172.22.200.7 443 extendable
R1(config)#ip nat inside source list PUBLICIP interface GigabitEthernet0/0/0 overload
R1#copy running-config startup-config
