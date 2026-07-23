param(
    [string]$Software,
    [string]$Target = ""
)

# ============================================================
# NHÂN CÁCH 1: JENKINS ĐANG GỌI -> RA LỆNH CHO MÁY ĐÍCH (WINRM)
# ============================================================
if ($Target -ne "") {
    Write-Host "`n===== TRIGGER REMOTE INSTALLATION ====="
    Write-Host "Target   : $Target"
    Write-Host "Software : $Software"

    # Gọi lệnh WinRM để thực thi script ĐÃ ĐƯỢC COPY SẴN trên máy Client ở bước Prepare
    Invoke-Command -ComputerName $Target -ScriptBlock {
        param($sw)
        # Tại máy Client, nó sẽ tự gọi file install.ps1 cục bộ
        & "C:\It-Support\SCM\scripts\install.ps1" -Software $sw
    } -ArgumentList $Software

    Write-Host "===== REMOTE INSTALLATION FINISHED ====="
    exit
}

# ============================================================
# NHÂN CÁCH 2: ĐANG CHẠY TRÊN MÁY ĐÍCH (LOCAL ROUTER)
# ============================================================
$TargetFolder = "C:\It-Support\SCM"

Write-Host "`n===== LOCAL INSTALL (ON AGENT) ====="
Write-Host "Software : $Software"

# Tìm installer đã được copy về ổ C:\It-Support\SCM
$Installer = Get-ChildItem -Path $TargetFolder -File -Include *.exe, *.msi | Select-Object -First 1

if ($null -eq $Installer) { throw "Không tìm thấy installer trên máy Client." }

# Chọn installer script
$InstallerFolder = Join-Path $PSScriptRoot "installer"
$CustomInstaller = Join-Path $InstallerFolder "$Software.ps1"
$DefaultInstaller = Join-Path $InstallerFolder "default.ps1"

if(Test-Path $CustomInstaller) {
    Write-Host "`nInstaller Script : $Software.ps1"
    & $CustomInstaller -Software $Software -Installer $Installer
} else {
    Write-Host "`nInstaller Script : default.ps1"
    & $DefaultInstaller -Software $Software -Installer $Installer
}
