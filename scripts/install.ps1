$TargetFolder = "C:\It-Support\SCM"

Write-Host ""
Write-Host "===== INSTALL ====="

$Installer = Get-ChildItem `
    -Path $TargetFolder `
    -Recurse `
    -Include *.msi,*.exe |
    Select-Object -First 1

if($null -eq $Installer)
{
    throw "Không tìm thấy file cài đặt (.msi hoặc .exe)"
}

Write-Host ""
Write-Host "Found Installer"

Write-Host "Name      : $($Installer.Name)"
Write-Host "Extension : $($Installer.Extension)"
Write-Host "Full Path : $($Installer.FullName)"

Write-Host ""
Write-Host "===== INSTALL SUCCESS ====="
