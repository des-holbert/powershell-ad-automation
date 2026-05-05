# Script 1: Bulk User Creation from CSV
# Purpose: Reads a CSV of new hires and creates AD accounts automatically
# Each user goes to the correct OU with the right security groups

Import-Module ActiveDirectory

$users = Import-Csv -Path "C:\Scripts\CSVs\NewHires.csv"
$domainPath = "DC=pinnaclesolutions,DC=local"

foreach ($user in $users) {

    $username = ($user.FirstName.Substring(0,1) + $user.LastName).ToLower()
    $ouPath = "OU=$($user.Department),OU=Users,OU=Dallas,$domainPath"
    $displayName = "$($user.FirstName) $($user.LastName)"
    $securePassword = ConvertTo-SecureString $user.Password -AsPlainText -Force

    New-ADUser `
        -SamAccountName $username `
        -UserPrincipalName "$username@pinnaclesolutions.local" `
        -Name $displayName `
        -GivenName $user.FirstName `
        -Surname $user.LastName `
        -DisplayName $displayName `
        -Title $user.Title `
        -Department $user.Department `
        -Path $ouPath `
        -AccountPassword $securePassword `
        -ChangePasswordAtLogon $true `
        -Enabled $true

    $groupName = switch ($user.Department) {
        "IT Department"    { "SG-IT" }
        "Human Resources"  { "SG-HR" }
        "Finance"          { "SG-Finance" }
        "Sales"            { "SG-Sales" }
        "Operations"       { "SG-Operations" }
    }

    Add-ADGroupMember -Identity $groupName -Members $username
    Add-ADGroupMember -Identity "DL-AllEmployees" -Members $username

    Write-Host "Created user: $displayName ($username) in $($user.Department)" -ForegroundColor Green
}

Write-Host "`nAll users created successfully." -ForegroundColor Cyan
