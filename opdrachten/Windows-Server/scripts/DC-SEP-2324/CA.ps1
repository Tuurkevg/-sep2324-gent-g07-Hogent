#CA params
$RootCAName = "Blame-Root-CA"
$CertificatePath ="C:\users\Administrator\Documents"
$SharedCAPath = "Z:\CA"
$SharedSSHPath = "$SharedCAPath\SSH-Keys"
$PasswordPFX = "Hogent2324"
$sshIP = "192.168.107.164"
$SSHAccount = "vagrant"

$CAParams=@{
    CAType = "EnterpriseRootCA"
    CryptoProviderName = "RSA#Microsoft Software Key Storage Provider"
    HashAlgorithmName = "SHA256"
    KeyLength = 2048
    ValidityPeriod = "Years"
    ValidityPeriodUnits = 10
    CACommonName = $RootCAName
    OverwriteExistingCAInDS = $true
    OverwriteExistingKey = $true
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

#request certificate
function RequestCertificate {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CAName,
        [Parameter(Mandatory=$true)]
        [string]$CertificateName,
        [Parameter(Mandatory=$true)]
        [String]$CertificatePath
    )
    try{
        #check if RPC service is running
        #if not start it and wait for it to start
        $service =(Get-Service -Name RpcSs)
        Write-Host "Checking if RPC service is running"
        if($service.Status -ne "Running"){
            Write-Host "Starting RPC service"
            Start-Service -Name RpcSs
            Write-Host "Waiting for RPC service to start"
            Start-Sleep -Seconds 5
            $Service.refresh()
        }
        Write-Host "RPC service is running"
    }catch{
        Write-Host "An error occured: $_"
    }
try{
#check if CA already exists
if (-not (Test-Path -Path $CertificatePath)){
    New-Item -Path $CertificatePath -ItemType Directory
}
#check if shared path exists
if (-not (Test-Path -Path $SharedCAPath)){
    New-Item -Path $SharedCAPath -ItemType Directory
}

    #request certificate
    certreq -new "$SharedCAPath\certificate-request-$CertificateName.inf" "$CertificatePath\$CertificateName.csr"

    #submit request
    certreq -submit -config "$env:COMPUTERNAME\$CAName" "$CertificatePath\$CertificateName.csr" "$CertificatePath\$CertificateName.cer"

    #remove rsp and csr files
    Remove-Item -Path "$CertificatePath\$CertificateName.rsp"
    Remove-Item -Path "$CertificatePath\$CertificateName.csr"

}catch{
    Write-Host "An error occured: $_"
}
}

#export certificate
function ExportCertificate {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CertificateName,
        [Parameter(Mandatory=$true)]
        [string]$CertificatePath,
        [bool]$rootCertificate = $false
    )
        #check if certificate exists
        if (-not (Test-Path -Path "$CertificatePath\$CertificateName.cer")){
            Write-Host "Certificate does not exist"
        
        }
        if($rootCertificate -eq $true){
            #check if root certificate already exists
            if (-not (Test-Path -Path "$CertificatePath\root.cer")){
                Write-Host "Root certificate is requested"
            #Get the roota certificate by name
            $cert = Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object {$_.Subject -like "*$CertificateName*"}
            $cert[0].PSPath
            #Export the certificate
            Export-Certificate -Cert $cert[0].PSPath -FilePath "$CertificatePath"
            }
        }

        elseif($rootCertificate -eq $false){
            #check if the pfx already exists
            if (-not (Test-Path -Path "$CertificatePath\$CertificateName.pfx")){
            Write-Host "Root certificate is not requested"
            #import certificate
            $CertThumbprint =(Import-Certificate -FilePath "$CertificatePath\$CertificateName.cer" -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
            $CertThumbprint
            $cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Thumbprint -eq $CertThumbprint}
            $cert
            Export-PfxCertificate -Cert $cert[0].PSPath -FilePath "$CertificatePath\$CertificateName.pfx" -Password (ConvertTo-SecureString -String $PasswordPFX -Force -AsPlainText)
        }
       
    }
}

    function SSHConnection{
        param(
            [Parameter(Mandatory=$true)]
            [string]$CertificateName)

        #check if openSSH client and server are installed
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 -ErrorAction SilentlyContinue
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue

        #check if sshd service is running
        $service = Get-Service -Name sshd
        if($service.Status -ne "Running"){
            Start-Service -Name sshd
            Set-Service -Name sshd -StartupType 'Automatic'
        }

        #Check if ssh directory exists and create it if it doesn't
        if (-not (Test-Path -Path "$env:USERPROFILE\.ssh")){
            New-Item -Path "$env:USERPROFILE\.ssh" -ItemType Directory
        }
        
        #Check if SSH keys exist and copy them to the user profile if they don't
        if (-not (Test-Path -Path "$env:USERPROFILE\.ssh\id_rsa")){
            Copy-Item -Path "$SharedSSHPath\id_rsa" -Destination "$env:USERPROFILE\.ssh\id_rsa" -Force
        } else {
            Write-Host "SSH private key already exists"
        }
        if (-not (Test-Path -Path "$env:USERPROFILE\.ssh\id_rsa.pub")){
            Copy-Item -Path "$SharedSSHPath\id_rsa.pub" -Destination "$env:USERPROFILE\.ssh\id_rsa.pub" -Force
        }else {
            Write-Host "SSH public key already exists"
        }
        #copy certificate to remote server
        scp "$Certificatepath\$CertificateName.pfx" "${SSHAccount}@${sshIP}:$CertificateName.pfx"

        #connect to remote server and extract certificate
        Write-Host "Converting the web certificate public key"
        ssh ${SSHAccount}@${sshIP}  "sudo openssl pkcs12 -in $CertificateName.pfx -clcerts -nokeys -out /etc/nginx/ssl/g07-blame.internal.crt -passin pass:$PasswordPFX"
        Write-Host "Converting the web certificate private key"
        ssh ${SSHAccount}@${sshIP} "sudo openssl pkcs12 -in $CertificateName.pfx -nocerts -nodes -passin pass:$PasswordPFX | sudo openssl rsa -out /etc/nginx/ssl/g07-blame.internal.key"

        #clean up and restart remote server
        ssh ${SSHAccount}@${sshIP} "rm $CertificateName.pfx"
        ssh ${SSHAccount}@${sshIP} "sudo systemctl restart nginx"

    }

#Install CA
InstallCAServer
#Request certificate
RequestCertificate -CertificateName 'web' -CAName $RootCAName -CertificatePath $CertificatePath
#Export certificate
ExportCertificate -CertificateName 'web' -CertificatePath $CertificatePath
ExportCertificate -CertificateName $RootCAName -CertificatePath "$CertificatePath\root.cer" -rootCertificate $true
#SSH connection
SSHConnection -certificateName 'web'

