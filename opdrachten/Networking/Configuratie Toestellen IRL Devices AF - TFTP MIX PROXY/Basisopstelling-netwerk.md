# Basisopstelling netwerk

X: tafelnummer

# S1

Console -> X/7
Fa4 (Extra LinuxCLI) -> X/15
Fa5 (WinServ) -> X/10
Fa6 (LinuxCLI) -> X/11
Fa10 (Proxy) -> X/12
Fa23 (TFTP) -> X/13
Fa24 (WinClient) -> X/14

# R1

Console -> X/8
G0/0/1 -> S1 - G0/1
G0/0/0 -> ISP

# R2

Console -> X/9
G0/0/1 -> S1 - G0/2
G0/0/0 -> ISP
