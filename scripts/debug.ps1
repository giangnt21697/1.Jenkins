Write-Host ""
Write-Host "==============================================="
Write-Host "           JENKINS DEBUG INFORMATION"
Write-Host "==============================================="
Write-Host ""

Write-Host "[1] Computer Name"
Write-Host "    $env:COMPUTERNAME"
Write-Host ""

Write-Host "[2] Current User"
Write-Host "    $env:USERNAME"
Write-Host ""

Write-Host "[3] Windows Identity"
Write-Host "    $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
Write-Host ""

Write-Host "[4] PowerShell Version"
Write-Host "    $($PSVersionTable.PSVersion)"
Write-Host ""

Write-Host "[5] Current Directory"
Write-Host "    $(Get-Location)"
Write-Host ""

Write-Host "[6] Workspace"
Write-Host "    $env:WORKSPACE"
Write-Host ""

Write-Host "[7] Target Folder"

$TargetFolder = "C:\It-Support\SCM"

if(Test-Path $TargetFolder)
{
    Write-Host "    EXISTS"

    $item = Get-Item $TargetFolder

    Write-Host "    FullName   : $($item.FullName)"
    Write-Host "    Attributes : $($item.Attributes)"
}
else
{
    Write-Host "    NOT FOUND"
}

Write-Host ""

Write-Host "[8] Network Share"

$Share = "\\10.2.15.93\Setup"

if(Test-Path $Share)
{
    Write-Host "    CONNECTED"

    $folders = Get-ChildItem $Share -Directory

    Write-Host "    Total Software : $($folders.Count)"

    $folders |
        Select-Object -First 5 |
        ForEach-Object{
            Write-Host "      - $($_.Name)"
        }
}
else
{
    Write-Host "    CANNOT ACCESS"
}

Write-Host ""

Write-Host "==============================================="
Write-Host "             DEBUG FINISHED"
Write-Host "==============================================="
