param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host ""
Write-Host "Software : $Software"
Write-Host "Installer : $($Installer.Name)"
Write-Host ""

$Arguments = @(
    "/VERYSILENT",
    "/SUPPRESSMSGBOXES",
    "/NORESTART",
    "/SP-"
)

$Process = Start-Process `
    -FilePath $Installer.FullName `
    -ArgumentList $Arguments `
    -Wait `
    -PassThru

Write-Host "Exit Code : $($Process.ExitCode)"

if($Process.ExitCode -ne 0)
{
    throw "WinSCP installation failed."
}

Write-Host ""
Write-Host "===== INSTALL SUCCESS ====="
