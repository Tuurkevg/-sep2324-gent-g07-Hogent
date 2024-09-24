# Define the IP address range for the reverse lookup zone
$NetworkID = "192.168.107.0/24"
$IPv6NetworkID = "2001:db8:ac07::/48"

#hosts
[array]$Devices = @(
    [hashtable]@{
        Name = "TFTP"
        IP = "192.168.107.133"
        IPv6 = "2001:db8:ac07:1::5"
    },
    [hashtable]@{
        Name = "DC-SEP-2324"
        IP = "192.168.107.148"
        IPv6 = "2001:db8:ac07:42::4"
    },
    [hashtable]@{
        Name = "DB"
        IP = "192.168.107.149"
        IPv6 = "2001:db8:ac07:42::5"
    },
    [hashtable]@{
        Name = "WEB"
        IP = "192.168.107.150"
        IPv6 = "2001:db8:ac07:42::6"
    },
    [hashtable]@{
        Name = "EXTRA"
        IP = "192.168.107.151"
        IPv6 = "2001:db8:ac07:42::7"
    },
    [hashtable]@{
        Name = "DC-SEP-2324-Backup"
        IP = "192.168.107.152"
        IPv6 = "2001:db8:ac07:42::8"
    },
    [hashtable]@{
        Name = "RP"
        IP = "192.168.107.164"
        IPv6 = "2001:db8:ac07:13::4"
    },
    [hashtable]@{
        Name = "ISP"
        IP = "192.168.107.254"
        IPv6 = "2001:db8:ac07:150::10"
    }
)
#Crecord aliasses
  [String[]]$Aliasses = @(
    "www",
    "extra",
    "www.extra",
    "nextcloud",
    "www.nextcloud",
    "vaultwarden",
    "www.vaultwarden"
)
# Define the DNS server name
[String]$DNSServer = "DC-SEP-2324"
# Define the Zone variable
$ZoneName = "ad.g07-blame.internal"
#Secondary Zone
$SecondaryZone = "g07-blame.internal"

#Define the DHCP scope settings
$IPAddress = "192.168.107.148"
$SecondaryDNS = "192.168.107.152"
$DNSDomain = "g07-blame.internal"
$Gateway = "192.168.107.1"
$SubnetMask = "255.255.255.128"
$StartRange = "192.168.107.10"
$EndRange = "192.168.107.126"

#IPv6 settings
$IPv6Address = "2001:db8:ac07:42::4"
$SecondaryDNSIPv6 = "2001:db8:ac07:42::8"
$IPv6NetworkDHCP ="2001:db8:ac07:11::"

$ScopeName = "Vlan11"


#domain admin
$DomainAdmin = "G07-Blame\Administrator"

#check ipv4 if reverse lookup zone exists
#IPCheck
$parts = $NetworkID.Split(".")
$IPCheck =$parts[0..2] -join "."
# Split the IP address into octets
$Octets = $IPCheck -split '\.'

# Switch the first and last octets
$SwitchedIPAddress = $Octets[2] + "." + $Octets[1] + "." + $Octets[0]

$ReverseZone = $SwitchedIPAddress + ".in-addr.arpa"
# Check if the reverse lookup zone exists for the given IP address range
$ReverseZoneExists = Get-DnsServerZone -ComputerName $DNSServer | Where-Object { $_.ZoneName -eq "$ReverseZone" }

if ($ReverseZoneExists) {
    Write-Host "Reverse lookup zone $($ReverseZone) already exists."
} else {
    Write-Host "Reverse lookup zone $($ReverseZone) does not exist."
    Write-Host "Creating reverse lookup zone $($ReverseZone)..."
    Add-DnsServerPrimaryZone -NetworkID $NetworkID -Replicationscope Domain -DynamicUpdate Secure
    Write-Host "Reverse lookup zone $($ReverseZone) created."
}

#check if IPv6 reverse lookup zone exists
#Remove the ::/48 from the $IPv6NetworkID variable
$IPv6Network = $IPv6NetworkID -replace "::/48", ""

#split the variables into 3 parts delimited by ":"
$IPv6Numbers = $IPv6Network -split ":"

#if a part has less than 4 characters, add leading zeros
$IPv6Add0 = $IPv6Numbers | ForEach-Object { $_.PadLeft(4, "0") }

#Array
$IPv6Array = $IPv6Add0 | ForEach-Object { $_.ToCharArray() }

#reverse array
$Null= [array]::Reverse($IPv6Array)
$reverseIPv6Array = $IPv6Array

#join the array into a string with "." as delimiter
$IPv6ReverseString = $reverseIPv6Array -join "."

#Add the ip6.arpa suffix
$IPv6ReverseZone = $IPv6ReverseString + ".ip6.arpa"

#check if IPv6 reverse lookup zone exists
$IPv6ReverseZoneExists = Get-DnsServerZone -ComputerName $DNSServer | Where-Object { $_.ZoneName -eq "$IPv6ReverseZone" }

if ($IPv6ReverseZoneExists) {
    Write-Host "Reverse lookup zone $($IPv6ReverseZone) already exists."
} else {
    Write-Host "Reverse lookup zone $($IPv6ReverseZone) does not exist."
    Write-Host "Creating reverse lookup zone $($IPv6ReverseZone)..."
    Add-DnsServerPrimaryZone -NetworkID $IPv6NetworkID -Replicationscope Domain -DynamicUpdate Secure
    #allow secure secondaries
    Set-DnsServerPrimaryZone -Name $IPv6ReverseZone -DynamicUpdate Secure 
    Write-Host "Reverse lookup zone $($IPv6ReverseZone) created."
}


#create a second forward lookup zone
$ForwardZoneExists = Get-DNSServerZone -ComputerName $DNSServer | Where-Object { $_.ZoneName -eq "$SecondaryZone" }

if ($ForwardZoneExists) {
    Write-Host "Forward lookup zone $($SecondaryZone) already exists."
} else {
    Write-Host "Forward lookup zone $($SecondaryZone) does not exist."
    Write-Host "Creating forward lookup zone $($SecondaryZone)..."
    Add-DnsServerPrimaryZone -Name $SecondaryZone -ReplicationScope Domain -DynamicUpdate Secure 
    Write-Host "Forward lookup zone $($SecondaryZone) created."
}

Set-DnsServerPrimaryZone -Name $ZoneName -DynamicUpdate Secure 

# Convert the hashtable array to a 2D array
$2DArray = $Devices | ForEach-Object { [System.Management.Automation.PSObject]$_ }

# Create A records for each host IP address in the array
foreach ($Device in $2DArray)
{
    #check if the A record already exists
    $ARecordExists = Get-DnsServerResourceRecord -ZoneName $ZoneName -Name $Device.Name.ToLower() -ComputerName $DNSServer -ErrorAction SilentlyContinue
    if ($ARecordExists) {
        Write-Host "A record $($Device.Name.ToLower()) already exists."
        #remove the A record
        Remove-DnsServerResourceRecord -ZoneName $ZoneName -RRType "A" -Name $Device.Name.ToLower() -ComputerName $DNSServer -force -PassThru -ErrorAction SilentlyContinue
        Write-Host "A record $($Device.Name.ToLower()) removed."
    }
    #check if AAAA record already exists
    $AAAARecordExists = Get-DnsServerResourceRecord -ZoneName $ZoneName -Name $Device.Name.ToLower() -ComputerName $DNSServer -ErrorAction SilentlyContinue
    if ($AAAARecordExists) {
        Write-Host "AAAA record $($Device.Name.ToLower()) already exists."
        #remove the AAAA record
        Remove-DnsServerResourceRecord -ZoneName $ZoneName -RRType "AAAA" -Name $Device.Name.ToLower() -ComputerName $DNSServer -force -PassThru -ErrorAction SilentlyContinue
        Write-Host "AAAA record $($Device.Name.ToLower()) removed."
    }
    #check if the PTR record already exists
    $PTRRecordExists = Get-DnsServerResourceRecord -ZoneName $ReverseZone -Name $Device.IP.Split(".")[3] -ComputerName $DNSServer -ErrorAction SilentlyContinue
    if ($PTRRecordExists) {
        Write-Host "PTR record $($Device.IP.Split(".")[3]) already exists."
        #remove the PTR record
        Remove-DnsServerResourceRecord -ZoneName $ReverseZone -RRType "PTR" -Name $Device.IP.Split(".")[3] -ComputerName $DNSServer -force -PassThru -ErrorAction SilentlyContinue
        Write-Host "PTR record $($Device.IP.Split(".")[3]) removed."
    }
    #check if IPV6 PTR record already exists
    $IPv6PTRRecordExists = Get-DnsServerResourceRecord -ZoneName $IPv6ReverseZone -Name $Device.IPv6.Split(":")[3] -ComputerName $DNSServer -ErrorAction SilentlyContinue
    if ($IPv6PTRRecordExists) {
        Write-Host "PTR record $($Device.IPv6.Split(":")[3]) already exists."
        #remove the PTR record
        Remove-DnsServerResourceRecord -ZoneName $IPv6ReverseZone -RRType "PTR" -Name $Device.IPv6.Split(":")[3] -ComputerName $DNSServer -force -PassThru -ErrorAction SilentlyContinue
        Write-Host "PTR record $($Device.IPv6.Split(":")[3]) removed."
    }

    #if the name is rp
    if ($Device.Name.ToLower() -eq "rp") {
        #create A record
        Write-Host "Creating A record $($Device.Name.ToLower())..."
        Add-DnsServerResourceRecordA -ZoneName $SecondaryZone -Ipv4Address $Device.IP -Name "@" -CreatePtr -ErrorAction SilentlyContinue
        Add-DnsServerResourceRecordAAAA -ZoneName $SecondaryZone -IPv6Address $Device.IPv6 -Name "@" -CreatePtr -ErrorAction SilentlyContinue
        
    }else{
        #create A record
        Write-Host "Creating A record $($Device.Name.ToLower())..."
        Add-DnsServerResourceRecordA -ZoneName $ZoneName -Ipv4Address $Device.IP -Name $Device.Name.ToLower() -CreatePtr
        Add-DnsServerResourceRecordAAAA -ZoneName $ZoneName -IPv6Address $Device.IPv6 -Name $Device.Name.ToLower() -CreatePtr
    }
  }

foreach ($Alias in $Aliasses)
{
    #check if the CNAME record already exists
    $CNameRecordExists = Get-DnsServerResourceRecord -ZoneName $SecondaryZone -Name $Alias -ComputerName $DNSServer -ErrorAction SilentlyContinue
    if ($CNameRecordExists) {
        Write-Host "CNAME record $($Alias) already exists."
        #remove the CNAME record
        Remove-DnsServerResourceRecord -ZoneName $SecondaryZone -RRType "CNAME" -Name $Alias -ComputerName $DNSServer -force -PassThru
        Write-Host "CNAME record $($Alias) removed."
    }
    #create CNAME record
    Write-Host "Creating CNAME record $($Alias)..."
    Add-DnsServerResourceRecordCName -ZoneName $SecondaryZone -Name $Alias -HostNameAlias $SecondaryZone
}
    
#DHCP
#install DHCP
Install-WindowsFeature -Name DHCP -IncludeManagementTools
#security groups aanmaken
netsh dhcp add securitygroups
netsh dhcp server set dnscredentials

#DHCP IPv4
#add DHCP server
Add-DhcpServerInDC -DnsName $DNSDomain -IPAddress $IPAddress
#create scope, add the default gateway, dns server and root domain of AD
Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubnetMask -State Active -LeaseDuration 8.00:00:00
Set-DhcpServerv4OptionValue -DnsDomain $DNSDomain -DnsServer $IPAddress, $SecondaryDNS -Router $Gateway -force
#connect dhcp to dns
Set-DhcpServerv4DnsSetting -ComputerName $IPAddress -DynamicUpdates "Always" -DeleteDnsRROnLeaseExpiry $true -NameProtection $false 
#Authorize DHCP server
Add-DhcpServerInDC -DnsName $DNSDomain -IPAddress $IPAddress

#DHCP IPv6
#create scope, add the default gateway, dns server and root domain of AD
Add-DhcpServerv6Scope -Prefix $IPv6NetworkDHCP -Name $ScopeName -State Active
Set-DhcpServerv6OptionValue -DnsServer $IPv6Address, $SecondaryDNSIPv6 -DomainSearchList $DNSDomain -force
#connect dhcp to dns
Set-DhcpServerv6DnsSetting -ComputerName $IPAddress -DynamicUpdates "Always" -DeleteDnsRROnLeaseExpiry $true -NameProtection $false

#restart service
Restart-Service dhcpserver

#post install complete
Set-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 -Name ConfigurationState -Value 2

#Users csv location
$ADUsers = import-csv "Z:\Users.csv"
#gpo backup parameters
$params = @{
    BackupID = '0CB9F2FF-C660-41DF-BD75-11A08ADF6FFE'
    TargetName = 'Disable PowerShell'
    path = 'Z:\GPO Backups'
    CreateIfNeeded = $true
}
#domain admin

#create OU's
New-ADOrganizationalUnit -Name "Company" -Path "DC=ad,DC=g07-blame,DC=internal"
New-ADOrganizationalUnit -Name "Users" -Path "OU=Company,DC=ad,DC=g07-blame,DC=internal"
New-ADOrganizationalUnit -Name "Admins" -Path "OU=Company,DC=ad,DC=g07-blame,DC=internal"
New-ADOrganizationalUnit -Name "Guests" -Path "OU=Company,DC=ad,DC=g07-blame,DC=internal"

#create new groups
New-ADGroup -Name "Admins" -GroupScope Global -GroupCategory Security -Path "OU=Admins,OU=Company,DC=ad,DC=g07-blame,DC=internal"
New-ADGroup -Name "Guests" -GroupScope Global -GroupCategory Security -Path "OU=Guests,OU=Company,DC=ad,DC=g07-blame,DC=internal"
New-ADGroup -Name "Users" -GroupScope Global -GroupCategory Security -Path "OU=Users,OU=Company,DC=ad,DC=g07-blame,DC=internal"

#Install FileServerResourceManager
Install-WindowsFeature -Name FileAndStorage-Services

#List of departments
$Departments = @("Admins", "Guests", "Users")

#create folder structure
New-Item -Path "C:\Shares" -ItemType Directory
foreach ($Department in $Departments)
{
    New-Item -Path "C:\Shares\$Department" -ItemType Directory
}

foreach($User in $ADUsers)
{
    $Username = $User.username
    $Password = $User.password
    $FirstName = $User.firstname
    $LastName = $User.lastname
    $City = $User.city
    $Department = $User.department
    $Company = $User.company
    $JobTitle = $User.jobtitle
    $OU = $User.ou

    #check if user already exists in AD
    if(Get-ADUser -F {SamAccountName -eq "$Username"})
    {
        #If user does exist, give a warning
        Write-Warning "A user account with username $Username already exists in Active Directory."
    }
    else
    {
        #User does not exist then create a new user
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@ad.g07-blame.internal" `
            -Name "$FirstName $LastName" `
            -GivenName $FirstName `
            -Surname $LastName `
            -City $City `
            -Department $Department `
            -Company $Company `
            -Title $JobTitle `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true `
            -Path $OU `
            -ChangePasswordAtLogon $true
        
        #Add user to group
        If ($Department -eq "Admins")
        {
            Add-ADGroupMember -Identity "Admins" -Members $Username
        }
        ElseIf ($Department -eq "Guests")
        {
            Add-ADGroupMember -Identity "Guests" -Members $Username
        }
        ElseIf ($Department -eq "Users")
        {
            Add-ADGroupMember -Identity "Users" -Members $Username
        }
}
}

#personal shared folder
foreach($User in $ADUsers)
{
    $Username = $User.username
    $Department = $User.department
    #create share folder
    New-Item -Path "C:\Shares\$Department\$Username" -ItemType Directory
    #set permissions, only the user and the domain admin has access
    if($Department -eq "Admins")
    {
        New-SmbShare -Name $Username -Path "C:\Shares\$Department\$Username" -FullAccess $Username, $DomainAdmin
    }elseif($Department -eq "Guests")
    {
        New-SmbShare -Name $Username -Path "C:\Shares\$Department\$Username" -FullAccess $Username, $DomainAdmin
    }elseif($Department -eq "Users")
    {
        New-SmbShare -Name $Username -Path "C:\Shares\$Department\$Username" -FullAccess $Username, $DomainAdmin
    }
}

#import gpo
import-gpo @params 
#link gpo to ou
New-GPLink -Name "Disable PowerShell" -Target "OU=Guests,OU=Company,DC=ad,DC=g07-blame,DC=internal" -Enforced Yes
New-GPLink -Name "Disable PowerShell" -Target "OU=Users,OU=Company,DC=ad,DC=g07-blame,DC=internal" -Enforced Yes 



#remove scheduled task
Unregister-ScheduledTask -TaskName "DNS&DHCP" -Confirm:$false