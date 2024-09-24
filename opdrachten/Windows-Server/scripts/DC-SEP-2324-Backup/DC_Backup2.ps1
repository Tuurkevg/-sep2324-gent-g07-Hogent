$BackupDnsName = "DC-SEP-2324-Bac.ad.g07-blame.internal"
$PrimaryDnsName = "DC-SEP-2324.ad.g07-blame.internal"
$IPAddress = "192.168.107.152"
$IPv4ScopeID = "192.168.107.0"
# Define the server role
$ServerRole = "Standby"

#install DHCP
Install-WindowsFeature -Name DHCP -IncludeManagementTools

#add security groups
netsh dhcp add securitygroups

#Add server to authorized DHCP servers
Add-DhcpServerInDC -DnsName $BackupDnsName -IPAddress $IPAddress

#Set the configuration state to complete
Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2

# Add DHCP ipv4 failover
Add-DhcpServerv4Failover -ComputerName $PrimaryDnsName -ServerRole $ServerRole -Partnerserver $BackupDnsName -Name "DHCP Failover" -ScopeID $IPv4ScopeID
