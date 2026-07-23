# ============================================================
# GREENSHOT CUSTOM INSTALLER
# ============================================================

param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

Write-Host "`n===== START CUSTOM INSTALLATION ====="
Write-Host "Software  : $Software"

if ($null -eq $Installer -or -not $Installer.Exists) {
    throw "LỖI: Không tìm thấy file Installer cho Greenshot."
}

Write-Host "Installer : $($Installer.Name)"
Write-Host "Path      : $($Installer.FullName)"
Write-Host "Engine    : Inno Setup (Hidden Metadata)`n"

# Greenshot sử dụng engine Inno Setup, các tham số này sẽ cài đặt ẩn hoàn toàn
$Arguments = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
Write-Host "Applying Switch : $Arguments" -ForegroundColor Cyan

try {
    # Cài đặt với Timeout 5 phút (300,000 ms) - Greenshot rất nhẹ nên cài khá nhanh
    $Process = Start-Process `
        -FilePath $Installer.FullName `
        -ArgumentList $Arguments `
        -PassThru `
        -ErrorAction Stop

    $Process.WaitForExit(300000) | Out-Null

    if (-not $Process.HasExited) {
        $Process.Kill()
        throw "Cài đặt Greenshot bị treo (Timeout 5 phút). Tiến trình đã bị ép đóng."
    }

    Write-Host "Exit Code : $($Process.ExitCode)"

    # Xử lý Exit Code (0 = thành công, 3010/1641 = cần restart)
    switch ($Process.ExitCode)
    {
        { $_ -in @(0, 3010, 1641) } 
        {
            Write-Host "`n===== INSTALL SUCCESS =====" -ForegroundColor Green
            if ($_ -in @(3010, 1641)) {
                Write-Host "CẢNH BÁO: Greenshot yêu cầu khởi động lại máy để hoàn tất!" -ForegroundColor Yellow
            }
            break
        }
        default 
        {
            throw "Greenshot cài đặt thất bại. Exit Code: $($Process.ExitCode)"
        }
    }
}
catch {
    Write-Host "LỖI HỆ THỐNG: $_" -ForegroundColor Red
    throw "Quá trình cài đặt bị gián đoạn."
}
