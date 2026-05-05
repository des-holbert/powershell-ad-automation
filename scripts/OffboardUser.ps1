# Script 3: Employee Offboarding — Disable Account & Strip Group Memberships
# Purpose: Disables a user account, removes all group memberships,
#          and moves the account to the Disabled Accounts OU

Import-Module ActiveDirectory

$username = Read-Host "Enter the username to offboard (e.g., tbrooks)"

$user = Get-ADUser -Identity $username -Properties DisplayName, MemberOf, DistinguishedName -ErrorAction SilentlyContinue

if ($user -eq $null) {
    Write-Host "User '$username' not found in Active Directory." -ForegroundColor Red
    return
}

Write-Host "`nUser found: $($user.DisplayName) ($username)" -ForegroundColor Yellow
Write-Host "This will:" -ForegroundColor Yellow
Write-Host "  1. Disable the account" -ForegroundColor Yellow
Write-Host "  2. Remove all group memberships" -ForegroundColor Yellow
Write-Host "  3. Move the account to Disabled Accounts OU" -ForegroundColor Yellow
$confirm = Read-Host "`nType YES to confirm"

if ($confirm -ne "YES") {
    Write-Host "Offboarding cancelled." -ForegroundColor Cyan
    return
}

Disable-ADAccount -Identity $username
Write-Host "`n[1/3] Account disabled." -ForegroundColor Green

$groups = Get-ADUser -Identity $username -Properties MemberOf | Select-Object -ExpandProperty MemberOf

foreach ($group in $groups) {
    $groupName = (Get-ADGroup $group).Name
    Remove-ADGroupMember -Identity $group -Members $username -Confirm:$false
    Write-Host "[2/3] Removed from group: $groupName" -ForegroundColor Green
}

$disabledOU = "OU=Disabled Accounts,DC=pinnaclesolutions,DC=local"
Move-ADObject -Identity $user.DistinguishedName -TargetPath $disabledOU
Write-Host "[3/3] Moved to Disabled Accounts OU." -ForegroundColor Green

Write-Host "`nOffboarding complete for $($user.DisplayName)." -ForegroundColor Cyan
Write-Host "Account is disabled, group memberships removed, moved to Disabled Accounts." -ForegroundColor Cyan
