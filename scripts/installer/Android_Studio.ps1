param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host ""
Write-Host "Software  : $Software"
Write-Host "Installer : $($Installer.Name)"
Write-Host ""

Write-Host "Android Studio Custom Install"

$Arguments = @(
    "/S",
    "/AllUsers"
)

$Process = Start-Process `
    -FilePath $Installer.FullName `
    -ArgumentList $Arguments `
    -Wait `
    -PassThru

Write-Host "Exit Code : $($Process.ExitCode)"

switch ($Process.ExitCode)
{
    0
    {
        Write-Host ""
        Write-Host "===== INSTALL SUCCESS ====="
        break
    }

    default
    {
        throw "Android Studio installation failed. Exit Code: $($Process.ExitCode)"
    }
}
