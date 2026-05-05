# Script 2: Password Reset with Forced Change at Next Logon
# Purpose: Resets a user's password and forces them to change it on next login

Import-Module ActiveDirectory

$username = Read-Host "Enter the username to reset (e.g., jhenderson)"

$user = Get-ADUser -Identity $username -Properties DisplayName -ErrorAction SilentlyContinue

if ($user -eq $null) {
    Write-Host "User '$username' not found in Active Directory." -ForegroundColor Red
    return
}

$tempPassword = ConvertTo-SecureString "TempPass2025!" -AsPlainText -Force

Set-ADAccountPassword -Identity $username -NewPassword $tempPassword -Reset
Set-ADUser -Identity $username -ChangePasswordAtLogon $true
Unlock-ADAccount -Identity $username

Write-Host "`nPassword reset complete." -ForegroundColor Green
Write-Host "User: $($user.DisplayName) ($username)" -ForegroundColor Green
Write-Host "Temporary password: TempPass2025!" -ForegroundColor Yellow
Write-Host "User must change password at next logon." -ForegroundColor Green
Write-Host "Account has been unlocked (if it was locked)." -ForegroundColor Green
