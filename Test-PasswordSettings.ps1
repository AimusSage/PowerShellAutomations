<#
.SYNOPSIS
A short example that illustrates password security in powershell

.DESCRIPTION
The script asks for user information and then outputs multiple ways this can be represented
It is recommended to use the get-credentials cmndlet to retreive secure userinformation. 
This demo is only for illustrative purposes.
#>

cls
write-host "For illustrative purposes only"
$userName = Read-host -Prompt "enter (example) Username: "
$securePassword = Read-Host -Prompt "Enter (example) Password: " -AsSecureString

# construct Credentials
$credentials = New-Object System.Management.Automation.PScredential -ArgumentList $userName, $securePassword

# convert securestring to plain text for storing password (if required)
$SecureStringAsPlainText = $SecurePassword | ConvertFrom-SecureString

# 'decrypt' securePassword to string using a BSTR pointer
$BSTR = `
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)

$stringPassword =   [System.Runtime.interopServices.Marshal]::PtrToStringAuto($BSTR)

# 'decrypt' secureStringAsPlaintext to readable password:
$reversedSecureString = $SecureStringAsPlainText | ConvertTo-SecureString
$BSTR = `
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($reversedSecureString)

$stringPasswordFromSecureStringAsPlainText =   [System.Runtime.interopServices.Marshal]::PtrToStringAuto($BSTR)

$message = "Credentials are: `username: " + $credentials.UserName + "`password: " + $credentials.GetNetworkCredential().Password + "`
The password is (should be equal to above password from credentials): $stringPassword 
The plaint text secure string of the password for storing credentials:`
$SecureStringAsPlainText `n `
Reverting the plain text to securestring to readable format results in: $stringPasswordFromSecureStringAsPlainText 
"
#write demo case to console
write-output $message

# using get-credentials method
Clear-Variable credentials 
Clear-Variable stringPassword

$credentials = Get-Credential -Message "Get-Credential Method: Please insert Userinfo"

$stringPassword = $credentials.GetNetworkCredential().Password
$message = "The credentials as provided are: " + "`
username: " + $credentials.UserName + "`
password: $stringPassword" 

Write-Output $message

Read-Host "Press Enter to exit demo"
