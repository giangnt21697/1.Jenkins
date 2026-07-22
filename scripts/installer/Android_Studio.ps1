# ============================================================
# Android Studio Installer
#
# Custom installer cho Android Studio.
# Sử dụng khi phần mềm cần cách cài riêng.
#
# ============================================================

param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host ""
Write-Host "Software : $Software"

if (-not $Installer)
{
    throw "Installer not found."
}

Write-Host ""
Write-Host "Installer : $($Installer.Name)"
Write-Host ""

switch ($Installer.Extension.ToLower())
{
    ".msi"
    {
        $Process = Start-Process `
            msiexec.exe `
            -ArgumentList "/i `"$($Installer.FullName)`" /qn /norestart" `
            -Wait `
            -PassThru

        if ($Process.ExitCode -ne 0)
        {
            throw "MSI installation failed."
        }

        break
    }

    ".exe"
    {
        Write-Host "Android Studio Custom Install"

        $Process = Start-Process `
            -FilePath $Installer.FullName `
            -ArgumentList "/S" `
            -Wait `
            -PassThru

        Write-Host "Exit Code : $($Process.ExitCode)"

        if ($Process.ExitCode -ne 0)
        {
            throw "Android Studio installation failed."
        }

        break
    }

    default
    {
        throw "Unsupported installer type."
    }
}

Write-Host ""
Write-Host "===== INSTALL SUCCESS ====="
