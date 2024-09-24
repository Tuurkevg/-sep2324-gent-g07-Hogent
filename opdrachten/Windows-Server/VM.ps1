# network name and range

<# $NetworkName = "SEP-23-24"
$NetworkRange = "192.168.107.0/24"
 #>

 $Adapter_Antwoord = ""

#ISO files
$WIN_Server_ISO = "Server.iso"
$WIN_Client_ISO = "Client.iso"

# paths
$WIN_PATH = $(Split-Path $MyInvocation.MyCommand.Path -Parent)
[String]$WIN_ISOPath = "${WIN_PATH}\ISO"
[String]$WIN_ScriptPath = "${WIN_PATH}\Scripts"

$WIN_vbvmspath = ""
#VM names
$WIN_DCNAME = "DC-SEP-2324"
$WIN_DCBackupNAME = "DC-SEP-2324-Backup"
$WIN_ClientNAME = "Client-SEP-2324"
#VDI
$WIN_DCVDI = "DC.vdi"
$WIN_BackupName = "Backup.vdi"
$WIN_ClientVDI = "Client.vdi"

#VDI size
#30GB = 30720
$VDI_Size=30720

#Operating system
$WIN_DCOS = "Windows2022_64"
$WIN_ClientOS = "Windows10_64"

#Ram
#3GB = 3072
$WIN_DC_RAM = 3072
$WIN_Client_RAM = 3072


# functies
function hoofding () {
    Write-Host "**********************************************************************"
    Write-Host "*                          SEP 23-24                                 *"
    Write-Host "**********************************************************************"
    Write-Host "* Academiejaar 2023 - 2024                                           *"
    Write-Host "**********************************************************************"
    Write-Host "* Lauwers Emiel                                                      *"
    Write-Host "**********************************************************************"
    Write-Host ""
}

<# function Network () {
    Write-Host ""
    Write-Host "**********************************************************************"
    Write-Host "* Setting up Network                                                 *"
    Write-Host "**********************************************************************"
    Write-Host ""
} #>

function print_bestaad_reeds () {
    Write-Host ""
    Write-Host "**********************************************************************"
    Write-Host "* Opgelet, deze VM bestaat reeds!                                    *"
    Write-Host "**********************************************************************"
    Write-Host ""
}

function bestaande_vm_opties () {
    Write-Host "**********************************************************************"
    Write-Host "* Wat wil je doen met deze bestaande VM?                             *"
    Write-Host "**********************************************************************"
    Write-Host "* 1) Opzetten van deze VM overslaan                                  *"
    Write-Host "* 2) Deze VM deleten en opnieuw instellen                            *"
    Write-Host "**********************************************************************"
    Write-Host "* 9) Dit script volledig stoppen                                     *"
    Write-Host "**********************************************************************"
    Write-Host ""
}

#locatie van de VM's
function vms_locatie () {
    Write-Host "**********************************************************************"
    Write-Host "* Wat is de installatiefolder van je VM's?                           *"
    Write-Host "**********************************************************************"
    Write-Host "* 1) Standaard (C:\Users\<username>\VirtualBox VMs)                  *"
    Write-Host "* 2) Zelf een path ingeven                                           *"
    Write-Host "**********************************************************************"
    Write-Host "* 9) Dit script volledig stoppen                                     *"
    Write-Host "**********************************************************************" 
}

#controle of vmboxmanage correct is geïnstalleerd
function controle_vboxmanage ($tmp_path){
    Write-Host "**********************************************************************"
    Write-Host "* Controle of VBoxManage correct is geinstalleerd                    *"
    Write-Host "**********************************************************************"
    Write-Host ""
    if ( $null -eq (get-command VBoxManage.exe -errorAction silentlyContinue)) {
        write-host "> Adding ${tmp_path} to Env:Path"
        write-host ""
        $env:path="${tmp_path};$env:path"
    }
    else {
        write-host "> VBoxManage is reeds geinstalleerd"
        write-host ""
    }
    if ( $null -eq (get-command VBoxManage.exe -errorAction silentlyContinue)) {
        write-host "> VBoxManage is niet geïnstalleerd, gelieve dit eerst te doen"
        write-host "> https://www.virtualbox.org/wiki/Downloads"
        write-host ""
        write-host "> Dit script wordt nu afgesloten"
        write-error "" -ErrorAction Stop
    }
}

#ontroleren of ingevoerde waarde geldig is
function Check_Input ([String[]]$ValidInput) {
    $input_user = Read-Host "> Keuze"

    if (${input_user} -in $ValidInput) {
        if(${input_user} -eq "9") {
            write-host "> Dit script wordt nu afgesloten"
            write-error "" -ErrorAction Stop 
        }
        return ${input_user}
}
return ""
}

function locatie_vms ($input_user){
    while (${input_user} -eq "") {
        vms_locatie
        $input_user = Check_Input "1","2","9"
    }
    switch ($input_user) {
        1 {
            $name = $env:USERNAME
            return "C:\Users\$name\VirtualBox VMs"
        }
        2 {
            $tmp_loc = Read-Host "> Geef het path in naar de locatie van je VM's in."
            return $tmp_loc
        }
        default {
            return "ERROR"
        }
    }
}

function Check_Of_Reeds_Bestaad{
    param($tmp_vmname)
    if ((vboxmanage list vms | select-string -Pattern "^""${tmp_vmname}""").count -gt 0) {
        return $true
    }
    return $false
}

function Check_of_runt{
    param($tmp_vmname)
    if ((vboxmanage list runningvms | select-string -Pattern "^""${tmp_vmname}""").count -gt 0) {
        return $true
    }
    return $false
}


function choose_adapter{

    #virtualbox show avaialbe adapters
    $NetAdapterList = (& VBoxManage.exe list bridgedifs| select-string "Name:"| select-string -NotMatch "HostInterfaceNetworking-") -replace "Name:",""
    #remove the spaces in front of the adapter names but keep the spaces in the name
    $NetAdapterList = $NetAdapterList -replace "^\s+",""
    #give each adapter a number and ask to select one
    $NetAdapterList | ForEach-Object -Begin { $i = 1 } -Process { Write-Host "$i. $_"; $i++ }
    $selected = Read-Host "Selecteer een adapter"
    #select the adapter
    $AdapterName = $NetAdapterList[$selected - 1]
    
    return $AdapterName
}

function setup_vm{
    param($tmp_vmname,  $tmp_vmostype, $tmp_ISOName, $tmp_VDIName, $tmp_VDI_Size, $tmp_ram)

    [String]$SharedFolder = "${WIN_ScriptPath}\${tmp_vmname}"

    write-host "> VM ${tmp_vmname} wordt aangemaakt"
    $tmp_watdoen = "2"
    if (Check_Of_Reeds_Bestaad "${tmp_vmname}") {
        print_bestaad_reeds
        $tmp_watdoen = ""
    }
    while (${tmp_watdoen} -eq "") {
        bestaande_vm_opties
        $tmp_watdoen = Check_Input @(1,2,3,9)
    }
    if (${tmp_watdoen} -eq "1") {
        write-host "> VM ${tmp_vmname} wordt niet aangemaakt"
        returns
    }
    else {
        while(Check_of_runt "${tmp_vmname}") {
            write-host "> VM ${tmp_vmname} wordt afgesloten"
            vboxmanage controlvm "${tmp_vmname}" poweroff
            write-host "> Sleeping for 5 seconds"
            start-sleep -s 5
        }
        while(Check_Of_Reeds_Bestaad "${tmp_vmname}") {
            write-host "> VM ${tmp_vmname} wordt verwijderd"
            vboxmanage unregistervm "${tmp_vmname}" --delete
            write-host "> Sleeping for 5 seconds"
            start-sleep -s 5
        }
    }

    #create vm
    write-host "> VM ${tmp_vmname} wordt aangemaakt"
    if(${WIN_vbvmspath} -eq "ERROR"){
        write-error "> De aangegeven locatie van je vm's is niet correct" -ErrorAction Stop
    }
    else{
        vboxmanage createvm --name "${tmp_vmname}" --ostype "${tmp_vmostype}" --register --basefolder "${WIN_vbvmspath}"
    }

    #set boot order
    write-host "> Boot order wordt aangepast"
    vboxmanage modifyvm "${tmp_vmname}" --boot1 disk --boot2 dvd --boot3 none --boot4 none

    #create sata controller
    write-host "> SATA controller wordt aangemaakt"
    vboxmanage storagectl "${tmp_vmname}" --name "SATA Controller" --add sata --controller IntelAhci

    #create vdi
    write-host "> VDI wordt aangemaakt"
    vboxmanage createhd --filename "${tmp_VDIName}" --size ${tmp_VDI_Size} --format VDI

    #attach VDI to sata controller
    write-host "> VDI wordt gekoppeld aan SATA controller"
    vboxmanage storageattach "${tmp_vmname}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${tmp_VDIName}"

    #create ide controller
    write-host "> IDE controller wordt aangemaakt"
    vboxmanage storagectl "${tmp_vmname}" --name "IDE Controller" --add ide --controller PIIX4
    <# #add nat network
    write-host "> Network wordt aangemaakt"
    vboxmanage modifyvm "${tmp_vmname}" --nic1 natnetwork --nat-network1 "${tmp_network}"#>

    #add bridged network
    write-host "> Bridged network wordt aangemaakt"
    write-host "AdapterName:" ${tmp_adapter}
    vboxmanage modifyvm "${tmp_vmname}" --nic1 bridged --bridgeadapter1 $AdapterName2

    #set video memory to 128MB
    write-host "> Video memory wordt aangepast naar 128MB"
    vboxmanage modifyvm "${tmp_vmname}" --vram 128
    #set 1 cpu
    write-host "> 1 CPU wordt toegewezen"
    vboxmanage modifyvm "${tmp_vmname}" --cpus 1
    #set ram
    write-host "> RAM wordt toegewezen"
    vboxmanage modifyvm "${tmp_vmname}" --memory ${tmp_ram}
    #graphics controller
    write-host "> Graphics controller wordt aangepast naar VBoxSVGA"
    vboxmanage modifyvm "${tmp_vmname}" --graphicscontroller VBoxSVGA
    write-host "> bidirectional clipboard wordt aangezet"
    vboxmanage modifyvm "${tmp_vmname}" --clipboard bidirectional
    #create shared folder
    write-host "> Shared folder wordt aangemaakt"
    vboxmanage sharedfolder add "${tmp_vmname}" --name "scripts" --hostpath "${SharedFolder}" --automount

    
    if ($tmp_vmname -eq "${WIN_ClientNAME}") {
        write-host "> Unattended install wordt uitgevoerd"
        Vboxmanage unattended install "${tmp_vmname}" `
        --iso="${WIN_ISOPath}\$tmp_ISOName" `
        --user="Administrator" `
        --password="Hogent2324" `
        --full-user-name="Administrator" `
        --install-additions `
        --image-index=2 `

        #start VM
        write-host "> VM wordt gestart"
        vboxmanage startvm "${tmp_vmname}"
    }else {
        write-host "> Unattended install wordt uitgevoerd"
        Vboxmanage unattended install "${tmp_vmname}" `
        --iso="${WIN_ISOPath}\$tmp_ISOName" `
        --user="Administrator" `
        --password="Hogent2324" `
        --full-user-name="Administrator" `
        --install-additions `
        --image-index=1 `
        
        #start VM
        write-host "> VM wordt gestart"
        vboxmanage startvm "${tmp_vmname}"
    }
}

<# function setup_network {
    if((vboxmanage.exe natnetwork list | select-string -Pattern "^Name:.*${NetworkName}").count -gt 0) {
        write-host "> Nat Network ${NetworkName} met range ${NetworkRange} bestaat reeds"
        Write-host "> Willen we dit netwerk verwijderen en opnieuw aanmaken? (y/n)"
        $Netwerk_Aanmaken = Read-Host
        while ($Netwerk_Aanmaken -ne "y" -and $Netwerk_Aanmaken -ne "n") {
            write-host "> Gelieve y of n in te geven"
        }
        if ($Netwerk_Aanmaken -eq "y") {
            write-host "> Nat Network ${NetworkName} wordt verwijderd"
            vboxmanage natnetwork remove --netname "${NetworkName}"
            write-host "> Nat Network ${NetworkName} wordt opnieuw aangemaakt"
            vboxmanage natnetwork add --netname "${NetworkName}" --network "${NetworkRange}" --enable --dhcp off
        } else {
            write-host "> Nat Network ${NetworkName} met range ${NetworkRange} wordt niet verwijderd"
        }
}
else {
    write-host "> Nat Network ${NetworkName} met range ${NetworkRange} bestaat nog niet"
    write-host "> Nat Network ${NetworkName} wordt aangemaakt"
    vboxmanage natnetwork add --netname "${NetworkName}" --network "${NetworkRange}" --enable --dhcp off
}
} #>

#main 
Clear-Host
hoofding

controle_vboxmanage "C:\Program Files\Oracle\VirtualBox"

$WIN_vbvmspath = locatie_vms ${WIN_vbvmspath}

<# #network aanmaken
$null = read-host "> Druk op enter om verder te gaan"
Clear-Host
write-host "> Wilt u het netwerk configureren (y/n)"
$Netwerk_Aanmaken = Read-Host "> Keuze"
#Als antwtoord niet y of n is, vraag opnieuw

if ($Netwerk_Aanmaken -ne "y" -and $Netwerk_Aanmaken -ne "n") {
    write-host "> Gelieve y of n in te geven"
    $Netwerk_Aanmaken = Read-Host "> Keuze"
}
if ($Netwerk_Aanmaken -eq "y") {
    setup_network
    $null = read-host "> Druk op enter om verder te gaan"
} #>

$null = read-host "> Druk op enter om verder te gaan"
Clear-Host
#Adapter kiezen
Write-Host "> Wilt u een adapter kiezen? (y/n)"
$Adapter_Antwoord = Read-Host "> Keuze"
#als antwoord niet y of n is, vraag opnieuw
if ($Adapter_Antwoord -ne "y" -and $Adapter_Antwoord -ne "n") {
    write-host "> Gelieve y of n in te geven"
    $Adapter_Antwoord = Read-Host "> Keuze"
}
if ($Adapter_Antwoord -eq "y") {
    $AdapterName2 = choose_adapter
}
$null = read-host "> Druk op enter om verder te gaan"
Clear-Host
#VM's aanmaken
#DC aanmaken
write-host "> Wilt u de Domain Controller aanmaken? (y/n)"
$DC_Antwoord = Read-Host "> Keuze"
#als antwoord niet y of n is, vraag opnieuw
if ($DC_Antwoord -ne "y" -and $DC_Antwoord -ne "n") {
    write-host "> Gelieve y of n in te geven"
    $DC_Antwoord = Read-Host "> Keuze"
} 
if ($DC_Antwoord -eq "y") {
    setup_vm "${WIN_DCNAME}" "${WIN_DCOS}" "${WIN_Server_ISO}" "${WIN_DCVDI}" "${VDI_Size}" "${WIN_DC_RAM}" 
} 

$null = read-host "> Druk op enter om verder te gaan"
Clear-Host

#Backup DC aanmaken
write-host "> Wilt u de Backup Domain Controller aanmaken? (y/n)"
$Backup_Antwoord = Read-Host "> Keuze"
#als antwoord niet y of n is, vraag opnieuw
if($Backup_Antwoord -ne "y" -and $Backup_Antwoord -ne "n") {
    write-host "> Gelieve y of n in te geven"
    $Backup_Antwoord = Read-Host "> Keuze"
}
if ($Backup_Antwoord -eq "y") {
    setup_vm "${WIN_DCBackupNAME}" "${WIN_DCOS}" "${WIN_Server_ISO}" "${WIN_BackupName}" "${VDI_Size}" "${WIN_DC_RAM}" 
}


$null = read-host "> Druk op enter om verder te gaan"
Clear-Host

#Client aanmaken
write-host "> Wilt u de Client aanmaken? (y/n)"
$Client_Antwoord = Read-Host "> Keuze"
#als antwoord niet y of n is, vraag opnieuw
while ($Client_Antwoord -ne "y" -and $Client_Antwoord -ne "n") {
    write-host "> Gelieve y of n in te geven"
    $Client_Antwoord = Read-Host "> Keuze"
} 
if ($Client_Antwoord -eq "y") {
    setup_vm "${WIN_ClientNAME}" "${WIN_ClientOS}" "${WIN_Client_ISO}" "${WIN_ClientVDI}" "${VDI_Size}" "${WIN_Client_RAM}"
} 

$null = read-host "> Druk op enter om verder te gaan"
Clear-Host

write-host "> Het script is voltooid"
write-host "> Druk op enter om af te sluiten"
$null = read-host
exit

