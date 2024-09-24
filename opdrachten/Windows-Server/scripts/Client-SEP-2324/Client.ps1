# Define the network interface name
$InterfaceName = "Ethernet"

# Define the IP configuration settings
$IPAddress = "192.168.107.20"
$SubnetMask = "24"
$Gateway = "192.168.107.1"
$PrimaryDNSServer = "192.168.107.148"
$BackupDNSServer = "192.168.107.152"

# Make client part of domain
$DomainName = "ad.g07-blame.internal"
$DomainAdmin = "Administrator"
$Password = ConvertTo-SecureString -AsPlainText "Hogent2324" -Force
$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList @($DomainAdmin, $Password)

#change keybord layout to NLD BEP
Set-WinUserLanguageList nl-BE -Force

# Set the static IP address, subnet mask, and default gateway
New-NetIPAddress -InterfaceAlias $InterfaceName -IPAddress $IPAddress -PrefixLength $SubnetMask
New-NetRoute -InterfaceAlias $InterfaceName -DestinationPrefix 0.0.0.0/0 -NextHop $Gateway

# Configure the DNS server settings
Set-DnsClientServerAddress -InterfaceAlias $InterfaceName -ServerAddresses $PrimaryDNSServer, $BackupDNSServer


#set screen saver timeout to never
Powercfg /Change monitor-timeout-ac 0
Powercfg /Change monitor-timeout-dc 0
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0

# RSAT-tools installeren (internet nodig)
$installedRSAT = Get-WindowsCapability -Name RSAT* -Online | Where-Object { $_.State -eq "Installed" }

if (!$installedRSAT) {
    Write-Host "RSAT-tools worden geïnstalleerd..."
    # Lijst van RSAT-tools
    $RsatFeatures = @(
        "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0",
        "Rsat.DHCP.Tools~~~~0.0.1.0",
        "Rsat.Dns.Tools~~~~0.0.1.0",
        "Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0",
        "Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0",
        "Rsat.ServerManager.Tools~~~~0.0.1.0",
        "Rsat.CertificateServices.Tools~~~~0.0.1.0"
    )
    foreach ($Feature in $RsatFeatures) {
        Add-WindowsCapability -Online -Name $Feature -Verbose
    }
    Write-Host "RSAT-tools zijn geïnstalleerd."
}
else {
    Write-Host "RSAT-tools zijn al geïnstalleerd."
}

# Installeren software Nextcloud
$NextcloudInstallerPath = "Z:\Nextcloud-3.13.0-x64.msi"

if (Test-Path $NextcloudInstallerPath) {
   
    Start-Process -FilePath $NextcloudInstallerPath -Wait
} else {
    Write-Host "Het pad naar het Nextcloud-installatiebestand is onjuist. Controleer de locatie."
}

# Installeren software Thunderbird
$ThunderbirdPath = "Z:\Thunderbird Setup 115.10.1.exe"

if (Test-Path $ThunderbirdPath) {
    
    Start-Process -FilePath $ThunderbirdPath -Wait
} else {
    Write-Host "Het pad naar het Thunderbird-installatiebestand is onjuist. Controleer de locatie."
}


#change ipv4 and ipv6 to dhcp
Set-NetIPInterface -InterfaceAlias $InterfaceName -Dhcp Enabled
Set-NetIPInterface -InterfaceAlias $InterfaceName -AddressFamily IPv6 -Dhcp Enabled

# Join domain and fill in password
Add-Computer -DomainName $DomainName -Credential $Credential -Restart -Force