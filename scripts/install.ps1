param(
    [string]$Software
)

$TargetFolder = "C:\It-Support\SCM"

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host ""
Write-Host "Software : $Software"

# ------------------------------------------------------------
# Tìm installer đã được prepare.ps1 copy về
# ------------------------------------------------------------

$Installer = Get-ChildItem `
    -Path $TargetFolder `
    -File `
    -Include *.exe, *.msi `
    -Recurse |
    Select-Object -First 1

if ($null -eq $Installer)
{
    throw "Không tìm thấy installer."
}

# ------------------------------------------------------------
# Chọn installer script
# ------------------------------------------------------------

$InstallerFolder = Join-Path $PSScriptRoot "installer"

$CustomInstaller = Join-Path $InstallerFolder "$Software.ps1"

$DefaultInstaller = Join-Path $InstallerFolder "default.ps1"

if(Test-Path $CustomInstaller)
{
    Write-Host ""
    Write-Host "Installer Script : $Software.ps1"

    & $CustomInstaller `
        -Software $Software `
        -Installer $Installer
}
else
{
    Write-Host ""
    Write-Host "Installer Script : default.ps1"

    & $DefaultInstaller `
        -Software $Software `
        -Installer $Installer
}
