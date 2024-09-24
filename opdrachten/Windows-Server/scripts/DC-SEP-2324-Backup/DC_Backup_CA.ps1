#subordinate CA
$CAParams=@{
    CAType = "EnterpriseSubordinateCA"
    ParentCA = "DC-SEP-2324.ad.g07-blame.internal\Blame-Root-CA"
}

#Install CA
function InstallCAServer {
    if((get-WindowsFeature -Name ADCS-Cert-Authority).Installed -eq $false){
        Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools
        Install-AdcsCertificationAuthority @CAParams
    }else{
        Write-Host "ADCS-Cert-Authority is already installed"
    }
}

InstallCAServer