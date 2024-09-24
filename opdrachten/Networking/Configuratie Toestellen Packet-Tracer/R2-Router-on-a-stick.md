#### Configuratie sub interface g0/1.1

R2(config)#interface g0/1.1
R2(config-subif)#description Default gateway vlan1
R2(config-subif)#encapsulation dot1Q 1
R2(config-subif)#ip address 192.168.107.131 255.255.255.240
R2(config-subif)#ipv6 address 2001:db8:ac07:1::3/64

R2(config-subif)#standby 1 ip 192.168.107.129

R2(config-subif)#ip access-group NO-ACCESS-MANAGEMENT out

R2(config-subif)#ipv6 traffic-filter NO-ACCESS-MANAGEMENT-IPV6 out

#### Configuratie sub interface g0/1.11

R2(config)#interface g0/1.11
R2(config-subif)#description Default gateway vlan11
R2(config-subif)#encapsulation dot1Q 11
R2(config-subif)#ip address 192.168.107.3 255.255.255.128
R2(config-subif)#ipv6 address 2001:db8:ac07:11::3/64
R2(config-subif)#ip helper-address 192.168.107.148

R2(config-subif)#standby 1 ip 192.168.107.1

R2(config-subif)#ip access-group NO-ACCESS-INTERNAL-CLIENTS out

R2(config-subif)#ipv6 traffic-filter NO-ACCESS-INTERNAL-CLIENTS-IPV6 out

#### Configuratie sub interface g0/1.13

R2(config)#interface g0/1.13
R2(config-subif)#description Default gateway vlan13
R2(config-subif)#encapsulation dot1Q 13
R2(config-subif)#ip address 192.168.107.163 255.255.255.248
R2(config-subif)#ipv6 address 2001:db8:ac07:13::3/64

R2(config-subif)#standby 1 ip 192.168.107.161

R2(config-subif)#ip access-group NO-ACCESS-PROXY out

R2(config-subif)#ipv6 traffic-filter NO-ACCESS-PROXY-IPV6 out

#### Configuratie sub interface g0/1.42

R2(config)#interface g0/1.42
R2(config-subif)#description Default gateway vlan42
R2(config-subif)#encapsulation dot1Q 42
R2(config-subif)#ip address 192.168.107.147 255.255.255.240
R2(config-subif)#ipv6 address 2001:db8:ac07:42::3/64

R2(config-subif)#standby 1 ip 192.168.107.145

R2(config-subif)#ip access-group NO-ACCESS-INTERNAL-SERVER out

R2(config-subif)#ipv6 traffic-filter NO-ACCESS-INTERNAL-SERVER-IPV6 out

#### Configuratie interface g0/1

R2(config-if)#no shut

#### Configuratie interface g0/0

R2(config)#interface g0/0
R2(config-if)#description Connection to ISP switch
R2(config-if)#ip address 192.168.107.251 255.255.255.248
R2(config-if)#ipv6 address 2001:db8:ac07:150::3/64
R2(config-if)#no shut

### ACL

#### NO-ACCESS-MANAGEMENT

R2(config)#ip access-list standard NO-ACCESS-MANAGEMENT
R2(config-std-nacl)#permit 192.168.107.128 0.0.0.15
R2(config-std-nacl)#deny any

#### NO-ACCESS-VLAN-INTERNAL

R2(config)#ip access-list standard NO-ACCESS-VLAN-INTERNAL
R2(config-std-nacl)#permit 192.168.107.0 0.0.0.127
R2(config-std-nacl)#permit 192.168.107.160 0.0.0.7
R2(config-std-nacl)#permit 192.168.107.144 0.0.0.15
R2(config-std-nacl)#deny any

#### NO-ACCESS-PROXY

R2(config)#ip access-list extended NO-ACCESS-PROXY
R2(config-ext-nacl)#permit tcp any any eq 80
R2(config-ext-nacl)#permit tcp any any eq 443
R2(config-ext-nacl)#deny ip any any

#### NO-ACCESS-MANAGEMENT-IPV6

R2(config)#ipv6 access-list NO-ACCESS-MANAGEMENT-IPV6
R2(config-ipv6-acl)#permit ipv6 2001:db8:ac07:1::/64 any

#### NO-ACCESS-INTERNAL-SERVER-IPV6

R2(config)#ipv6 access-list NO-ACCESS-INTERNAL-SERVER-IPV6
R2(config-ipv6-acl)#permit ipv6 2001:db8:ac07:11::/64 any
R2(config-ipv6-acl)#permit ipv6 2001:db8:ac07:13::/64 any
R2(config-ipv6-acl)#permit ipv6 2001:db8:ac07:42::/64 any

#### NO-ACCESS-INTERNAL-CLIENTS-IPV6

R2(config)#ipv6 access-list NO-ACCESS-INTERNAL-CLIENTS-IPV6
R2(config-ipv6-acl)#permit ipv6 2001:db8:ac07:11::/64 any
R2(config-ipv6-acl)#permit ipv6 2001:db8:ac07:13::/64 any
R2(config-ipv6-acl)#permit ipv6 2001:db8:ac07:42::/64 any
R2(config-ipv6-acl)#permit tcp any any established

#### NO-ACCESS-PROXY-IPV6

R2(config)#ipv6 access-list NO-ACCESS-PROXY-IPV6
R2(config-ext-nacl)#permit tcp any any eq 80
R2(config-ext-nacl)#permit tcp any any eq 443

#### Extra

R2(config)#ipv6 unicast-routing
R2#copy running-config startup-config
