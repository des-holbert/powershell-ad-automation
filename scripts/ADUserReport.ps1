# Script 4: AD User Report — Export Users by OU or Security Group
# Purpose: Pulls a list of users from a specific OU or security group
#          and exports it to a CSV file

Import-Module ActiveDirectory

Write-Host "What type of report do you need?" -ForegroundColor Cyan
Write-Host "  1. All users in a department (OU)" -ForegroundColor Cyan
Write-Host "  2. All members of a security group" -ForegroundColor Cyan
$choice = Read-Host "`nEnter 1 or 2"

if ($choice -eq "1") {

    Write-Host "`nAvailable departments:" -ForegroundColor Yellow
    Write-Host "  IT Department" -ForegroundColor Yellow
    Write-Host "  Human Resources" -ForegroundColor Yellow
    Write-Host "  Finance" -ForegroundColor Yellow
    Write-Host "  Sales" -ForegroundColor Yellow
    Write-Host "  Operations" -ForegroundColor Yellow

    $department = Read-Host "`nEnter the department name exactly as shown"
    $ouPath = "OU=$department,OU=Users,OU=Dallas,DC=pinnaclesolutions,DC=local"

    $results = Get-ADUser -Filter * -SearchBase $ouPath -Properties DisplayName, Title, Department, EmailAddress, Enabled |
        Select-Object DisplayName, SamAccountName, Title, Department, Enabled

    $fileName = "C:\Scripts\CSVs\Report_$($department -replace ' ','_')_$(Get-Date -Format 'yyyy-MM-dd').csv"

}
elseif ($choice -eq "2") {

    Write-Host "`nCommon security groups:" -ForegroundColor Yellow
    Write-Host "  SG-IT" -ForegroundColor Yellow
    Write-Host "  SG-HR" -ForegroundColor Yellow
    Write-Host "  SG-Finance" -ForegroundColor Yellow
    Write-Host "  SG-Sales" -ForegroundColor Yellow
    Write-Host "  SG-Operations" -ForegroundColor Yellow
    Write-Host "  SG-VPN-Users" -ForegroundColor Yellow
    Write-Host "  SG-RemoteDesktop-Users" -ForegroundColor Yellow

    $groupName = Read-Host "`nEnter the group name exactly as shown"

    $results = Get-ADGroupMember -Identity $groupName |
        Get-ADUser -Properties DisplayName, Title, Department, Enabled |
        Select-Object DisplayName, SamAccountName, Title, Department, Enabled

    $fileName = "C:\Scripts\CSVs\Report_$($groupName)_$(Get-Date -Format 'yyyy-MM-dd').csv"

}
else {
    Write-Host "Invalid choice. Please run the script again and enter 1 or 2." -ForegroundColor Red
    return
}

if ($results.Count -eq 0) {
    Write-Host "`nNo users found. Check the OU or group name and try again." -ForegroundColor Red
    return
}

Write-Host "`nFound $($results.Count) users:`n" -ForegroundColor Green
$results | Format-Table -AutoSize

$results | Export-Csv -Path $fileName -NoTypeInformation
Write-Host "Report saved to: $fileName" -ForegroundColor Green
