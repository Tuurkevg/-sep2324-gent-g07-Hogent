| Device                      | Interface   | IPv4 Address    | IPv4 SubnetMask     | IPv4 Default Gateway | IPv6 Address          | IPv6 SubnetMask | IPv6 Default Gateway |
| --------------------------- | ----------- | --------------- | ------------------- | -------------------- | --------------------- | --------------- | -------------------- |
| R1-Router-On-A-Stick        | G0/1.1      | 192.168.107.130 | 255.255.255.240 /28 | N/A                  | 2001:db8:ac07:1::2    | /64             | N/A                  |
|                             | G0/1.11     | 192.168.107.2   | 255.255.255.128 /25 | N/A                  | 2001:db8:ac07:11::2   | /64             | N/A                  |
|                             | G0/1.13     | 192.168.107.162 | 255.255.255.248 /29 | N/A                  | 2001:db8:ac07:13::2   | /64             | N/A                  |
|                             | G0/1.42     | 192.168.107.146 | 255.255.255.240 /28 | N/A                  | 2001:db8:ac07:42::2   | /64             | N/A                  |
|                             | G0/0        | 192.168.107.250 | 255.255.255.248 /29 | N/A                  | 2001:db8:ac07:150::2  | /64             | N/A                  |
|                             |             |                 |                     |                      |                       |                 |                      |
| R2-Router-On-A-Stick        | G0/1.1      | 192.168.107.131 | 255.255.255.240 /28 | N/A                  | 2001:db8:ac07:1::3    | /64             | N/A                  |
|                             | G0/1.11     | 192.168.107.3   | 255.255.255.128 /25 | N/A                  | 2001:db8:ac07:11::3   | /64             | N/A                  |
|                             | G0/1.13     | 192.168.107.163 | 255.255.255.248 /29 | N/A                  | 2001:db8:ac07:13::3   | /64             | N/A                  |
|                             | G0/1.42     | 192.168.107.147 | 255.255.255.240 /28 | N/A                  | 2001:db8:ac07:42::3   | /64             | N/A                  |
|                             | G0/0        | 192.168.107.251 | 255.255.255.248 /29 | N/A                  | 2001:db8:ac07:150::3  | /64             | N/A                  |
|                             |             |                 |                     |                      |                       |                 |                      |
| S1                          | SVI (vlan1) | 192.168.107.132 | 255.255.255.240 /28 | 192.168.107.129      | 2001:db8:ac07:1::4    | /64             | 2001:db8:ac07:1::1   |
|                             |             |                 |                     |                      |                       |                 |                      |
| TFTP (vlan1)                | Fa0         | 192.168.107.133 | 255.255.255.240 /28 | 192.168.107.129      | 2001:db8:ac07:1::5    | /64             | 2001:db8:ac07:1::1   |
|                             |             |                 |                     |                      |                       |                 |                      |
| WinServ (vlan42)            | Fa0         | 192.168.107.148 | 255.255.255.240 /28 | 192.168.107.145      | 2001:db8:ac07:42::4   | /64             | 2001:db8:ac07:42::1  |
|                             |             |                 |                     |                      |                       |                 |                      |
| LinuxCLI DB (vlan42)        | Fa0         | 192.168.107.149 | 255.255.255.240 /28 | 192.168.107.145      | 2001:db8:ac07:42::5   | /64             | 2001:db8:ac07:42::1  |
|                             |             |                 |                     |                      |                       |                 |                      |
| LinuxCLI WEB (vlan42)       | Fa0         | 192.168.107.150 | 255.255.255.240 /28 | 192.168.107.145      | 2001:db8:ac07:42::6   | /64             | 2001:db8:ac07:42::1  |
|                             |             |                 |                     |                      |                       |                 |                      |
| Extra Linux Server (vlan42) | Fa0         | 192.168.107.151 | 255.255.255.240 /28 | 192.168.107.145      | 2001:db8:ac07:42::7   | /64             | 2001:db8:ac07:42::1  |
|                             |             |                 |                     |                      |                       |                 |                      |
| Extra Win Server (vlan42)   | Fa0         | 192.168.107.152 | 255.255.255.240 /28 | 192.168.107.145      | 2001:db8:ac07:42::8   | /64             | 2001:db8:ac07:42::1  |
|                             |             |                 |                     |                      |                       |                 |                      |
| Proxy (vlan13)              | Fa0         | 192.168.107.164 | 255.255.255.248 /29 | 192.168.107.161      | 2001:db8:ac07:13::4   | /64             | 2001:db8:ac07:13::1  |
|                             |             |                 |                     |                      |                       |                 |                      |
| Winclient (vlan11)          | Fa0         | 192.168.107.4   | 255.255.255.128 /25 | 192.168.107.1        | 2001:db8:ac07:11::4   | /64             | 2001:db8:ac07:11::1  |
|                             |             |                 |                     |                      |                       |                 |                      |
| ISP (Router)                | G0/0        | 192.168.107.254 | 255.255.255.248 /29 | N/A                  | 2001:db8:ac07:150::10 | /64             | N/A                  |
|                             |             |                 |                     |                      |                       |                 |                      |

Virtual defualt gateway's

| Network | IPv4 virtual default gateway | IPv6 virtual default gateway |
| ------- | ---------------------------- | ---------------------------- |
| Vlan1   | 192.168.107.129              | 2001:db8:ac07:1::1           |
| Vlan11  | 192.168.107.1                | 2001:db8:ac07:11::1          |
| Vlan13  | 192.168.107.161              | 2001:db8:ac07:13::1          |
| Vlan42  | 192.168.107.145              | 2001:db8:ac07:42::1          |
| ISP     | 192.168.107.249              | 2001:db8:ac07:150::1         |

Interface Table

| Device | Interface | Connected Device            |
| ------ | --------- | --------------------------- |
| S1     | Fa0/1     | Reserved For Server         |
|        | Fa0/2     | Reserved For Server         |
|        | Fa0/3     | Reserved For Server         |
|        | Fa0/4     | Extra Linux Server (vlan42) |
|        | Fa0/5     | WinServ en extra (vlan42)   |
|        | Fa0/6     | LinuxCLI (vlan42)           |
|        | Fa0/7     | Reserved For Server         |
|        | Fa0/8     | Reserved For Server         |
|        | Fa0/9     | Reserved For Server         |
|        | Fa0/10    | Proxy (vlan13)              |
|        | Fa0/23    | TFTP (vlan1)                |
|        | Fa0/24    | Winclient (vlan11)          |
|        | G0/1      | R1-Router-on-a-stick        |
|        | G0/2      | R2-Router-on-a-stick        |
|        | SVI       | N/A                         |

Netwerk Addressen:
IPv4 address: 192.168.107.0
IPv6 address: 2001:db8:ac07::/48

Subnet Addressen:
VLAN 11 Werkstations employees: 126 hosts IPv4

- IPv4 Netwerk address: 192.168.107.0
- IPv4 Broadcast address: 192.168.107.127
- IPv4 Subnet mask: 255.255.255.128 /25
- IPv6 Netwerk address: 2001:db8:ac07:11::
- IPv6 Subnet mask: /64

VLAN 1 Network Management: 14 hosts IPv4

- IPv4 Netwerk address: 192.168.107.128
- IPv4 Broadcast address: 192.168.107.143
- IPv4 Subnet mask: 255.255.255.240 /28
- IPv6 Netwerk address: 2001:db8:ac07:1::
- IPv6 Subnet mask: /64

VLAN 42 Interne servers: 14 hosts IPv4

- IPv4 Netwerk address: 192.168.107.144
- IPv4 Broadcast address: 192.168.107.159
- IPv4 Subnet mask: 255.255.255.240 /28
- IPv6 Netwerk address: 2001:db8:ac07:42::
- IPv6 Subnet mask: /64

VLAN 13 DMZ: 6 hosts IPv4

- IPv4 Netwerk address: 192.168.107.160
- IPv4 Broadcast address: 192.168.107.167
- IPv4 Subnet mask: 255.255.255.248 /29
- IPv6 Netwerk address: 2001:db8:ac07:13::
- IPv6 Subnet mask: /64

Connectie Met ISP: 6 hosts IPv4

- IPv4 Netwerk address: 192.168.107.248
- IPv4 Broadcast address: 192.168.107.255
- IPv4 Subnet mask: 255.255.255.248 /29
- IPv6 Netwerk address: 2001:db8:ac07:150::
- IPv6 Subnet mask: /64
