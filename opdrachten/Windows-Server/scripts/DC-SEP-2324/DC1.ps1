#Define the interface name
$InterfaceName = "Ethernet"
#Define the IP configuration settings
$PrimaryDNS = "192.168.107.148"
$SecondaryDNS = "192.168.107.152"
<# $SubnetMask = "255.255.255.240" #>
$subnetlength = "28"
$Gateway = "192.168.107.145"

#define ipv6 address
$PrimaryDNSIPv6 = "2001:db8:ac07:42::4"
$SecondaryDNSIPv6 = "2001:db8:ac07:42::8"
$IPv6PrefixLength = 64  
$IPv6Gateway = "2001:db8:ac07:42::1"

#change keybord layout to NLD BEP
Set-WinUserLanguageList nl-BE -Force

#set ipv4 to static
Set-NetIPInterface -InterfaceAlias $InterfaceName -Dhcp Disabled
#Set the static IP address, subnet mask, and default gateway
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $PrimaryDNS -PrefixLength $subnetlength
New-NetRoute -InterfaceAlias $InterfaceName -DestinationPrefix 0.0.0.0/0 -NextHop $Gateway

#Set the DNS
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $PrimaryDNS, $SecondaryDNS

#change ipv6 to static
Set-NetIPInterface -InterfaceAlias $InterfaceName -AddressFamily IPv6 -Dhcp Disabled
#set ipv6 address
New-NetIPAddress -InterfaceAlias $InterfaceName -AddressFamily IPv6 -IPAddress $PrimaryDNSIPv6 -PrefixLength $IPv6PrefixLength
New-NetRoute -InterfaceAlias $InterfaceName -DestinationPrefix ::/0 -NextHop $IPv6Gateway

#Set IPV6 DNS
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $PrimaryDNSIPv6, $SecondaryDNSIPv6

#autorun powershell script once at startup after regular tasks
$Trigger1 = New-ScheduledTaskTrigger -AtStartup
$User = "NT AUTHORITY\SYSTEM"
$Action1 = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "Z:\DNS_Final.ps1"
Register-ScheduledTask -TaskName "DNS&DHCP" -Trigger $Trigger1 -User $User -Action $Action1 -RunLevel Highest -Force

#set screen saver timeout to never
Powercfg /Change monitor-timeout-ac 0
Powercfg /Change monitor-timeout-dc 0
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0

#firewall rules
# DNS firewall rules
New-NetFirewallRule -Name "Allow DNS" -DisplayName "Allow DNS" -Enabled True -Direction Inbound -Protocol UDP -Action Allow -LocalPort 53
New-NetFirewallRule -Name "Allow DNS TCP" -DisplayName "Allow DNS TCP" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 53

#open firewall for ports 135, 389 and 445
New-NetFirewallRule -Name "Allow RPC" -DisplayName "Allow RPC" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 135
New-NetFirewallRule -Name "Allow LDAP" -DisplayName "Allow LDAP" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 389
New-NetFirewallRule -Name "Allow SMB" -DisplayName "Allow SMB" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 445

#open firewall for ports 88, 464 and 3268
New-NetFirewallRule -Name "Allow Kerberos" -DisplayName "Allow Kerberos" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 88
New-NetFirewallRule -Name "Allow Kerberos UDP" -DisplayName "Allow Kerberos UDP" -Enabled True -Direction Inbound -Protocol UDP -Action Allow -LocalPort 88
New-NetFirewallRule -Name "Allow Kerberos kpasswd" -DisplayName "Allow Kerberos kpasswd" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 464
New-NetFirewallRule -Name "Allow Kerberos kpasswd UDP" -DisplayName "Allow Kerberos kpasswd UDP" -Enabled True -Direction Inbound -Protocol UDP -Action Allow -LocalPort 464
New-NetFirewallRule -Name "Allow LDAP GC" -DisplayName "Allow LDAP GC" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 3268

#firewall rules for file and printer sharing inbound and outbound
New-NetFirewallRule -Name "Allow File and Printer Sharing" -DisplayName "Allow File and Printer Sharing" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 137-139
New-NetFirewallRule -Name "Allow File and Printer Sharing" -DisplayName "Allow File and Printer Sharing" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 445
New-NetFirewallRule -Name "Allow File and Printer Sharing" -DisplayName "Allow File and Printer Sharing" -Enabled True -Direction Outbound -Protocol TCP -Action Allow -LocalPort 137-139
New-NetFirewallRule -Name "Allow File and Printer Sharing" -DisplayName "Allow File and Printer Sharing" -Enabled True -Direction Outbound -Protocol TCP -Action Allow -LocalPort 445

#allow ping inbound
New-NetFirewallRule -Name "Allow ICMPv4-In" -DisplayName "Allow ICMPv4-In" -Enabled True -Direction Inbound -Protocol ICMPv4 -Action Allow -Profile Any -LocalAddress Any -RemoteAddress Any
#allow ping outbound
New-NetFirewallRule -Name "Allow ICMPv4-Out" -DisplayName "Allow ICMPv4-Out" -Enabled True -Direction Outbound -Protocol ICMPv4 -Action Allow -Profile Any -LocalAddress Any -RemoteAddress Any

#allow ssh inbound
New-NetFirewallRule -Name "Allow SSH" -DisplayName "Allow SSH" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
#allow ssh outbound
New-NetFirewallRule -Name "Allow SSH" -DisplayName "Allow SSH" -Enabled True -Direction Outbound -Protocol TCP -Action Allow -LocalPort 22

# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

#active directory
# Install AD-Domain-Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

#DNS
#install the DNS server role
Install-WindowsFeature -Name DNS -IncludeManagementTools

#set forwarders
Set-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru

#promote to DC and configure AD DS
Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Hogent2324" -Force) `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "ad.g07-blame.internal" `
-DomainNetbiosName "G07-BLAME" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true

#wait for 5 seconds
Start-Sleep -s 5

#reboot the server
Restart-Computer -Force
