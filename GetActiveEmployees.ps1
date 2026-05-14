# Load ONLY the Users submodule (prevents function overflow)
Import-Module Microsoft.Graph.Users -ErrorAction Stop

# Connect if needed
if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "User.Read.All"
}

Write-Host "Retrieving active employee accounts..."

$users = Get-MgUser -All `
    -Property DisplayName,UserPrincipalName,Department,JobTitle,AccountEnabled,UserType |
    Where-Object {
        $_.AccountEnabled -eq $true -and
        $_.UserType -eq "Member"
    } |
    Select-Object DisplayName, UserPrincipalName, Department, JobTitle

if (-not $users) {
    Write-Error "Microsoft Graph returned no users."
    exit 1
}

$exportPath = "$env:USERPROFILE\Documents\Active_Employees.csv"
$users | Export-Csv $exportPath -NoTypeInformation -Encoding UTF8

Write-Host "✅ Export complete:"
Write-Host $exportPath
