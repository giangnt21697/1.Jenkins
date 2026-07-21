param(
    [string]$Software
)

$TargetFolder = "C:\It-Support\SCM"

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host ""
Write-Host "Software : $Software"

# Tìm file cài đặt
$Installer = Get-ChildItem `
    -Path $TargetFolder `
    -Recurse `
    -Include *.msi,*.exe |
    Select-Object -First 1

if ($null -eq $Installer)
{
    throw "Không tìm thấy file cài đặt (.msi hoặc .exe)"
}

Write-Host ""
Write-Host "Found Installer"

Write-Host "Name      : $($Installer.Name)"
Write-Host "Extension : $($Installer.Extension)"
Write-Host "Full Path : $($Installer.FullName)"

Write-Host ""

switch ($Installer.Extension.ToLower())
{
    ".msi"
    {
        Write-Host "Installer Type : MSI"
        Write-Host "Start Installing..."

        Start-Process `
            -FilePath "msiexec.exe" `
            -ArgumentList "/i `"$($Installer.FullName)`" /qn /norestart" `
            -Wait

        break
    }

    ".exe"
    {
        Write-Host "Installer Type : EXE"

        throw "Chưa cấu hình silent switch cho file EXE."
    }

    default
    {
        throw "Không hỗ trợ định dạng $($Installer.Extension)"
    }
}

Write-Host ""
Write-Host "===== INSTALL SUCCESS ====="
