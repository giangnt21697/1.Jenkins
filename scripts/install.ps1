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

    try {
        # Thêm ErrorAction Stop để bắt lỗi kết nối ngay lập tức
        Invoke-Command -ComputerName $Target -ErrorAction Stop -ScriptBlock {
            param($sw)
            & "C:\It-Support\SCM\scripts\install.ps1" -Software $sw
        } -ArgumentList $Software

        Write-Host "===== REMOTE INSTALLATION FINISHED ====="
    }
    catch {
        Write-Host "LỖI KẾT NỐI WINRM: Không thể ra lệnh cho máy $Target." -ForegroundColor Red
        Write-Host "Chi tiết: $_" -ForegroundColor Red
        throw "Remote Installation Failed!" # Ép Jenkins phải báo FAILED
    }
    exit
}

# ============================================================
# NHÂN CÁCH 2: ĐANG CHẠY TRÊN MÁY ĐÍCH (LOCAL ROUTER)
# ============================================================
$TargetFolder = "C:\It-Support\SCM"

Write-Host "`n===== LOCAL INSTALL (ON AGENT) ====="
Write-Host "Software : $Software"

$Installer = Get-ChildItem -Path $TargetFolder -File | Where-Object { $_.Extension -in @(".exe", ".msi") } | Select-Object -First 1

if ($null -eq $Installer) { throw "Không tìm thấy installer trên máy Client." }

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
