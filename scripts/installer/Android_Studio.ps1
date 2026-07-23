# ============================================================
# ANDROID STUDIO CUSTOM INSTALLER (Optimized for Jenkins CI/CD)
# ============================================================

param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

Write-Host ""
Write-Host "===== START CUSTOM INSTALLATION ====="
Write-Host "Software  : $Software"

if ($null -eq $Installer -or -not $Installer.Exists) {
    throw "LỖI: Không tìm thấy file Installer cho Android Studio."
}

Write-Host "Installer : $($Installer.Name)"
Write-Host "Path      : $($Installer.FullName)"
Write-Host "Engine    : NSIS Bootstrapper`n"

# Gộp tham số thành chuỗi duy nhất
$Arguments = "/S /AllUsers"
Write-Host "Applying Switch : $Arguments" -ForegroundColor Cyan

try {
    # Thực thi cài đặt với Timeout 15 phút (900,000 ms)
    $Process = Start-Process `
        -FilePath $Installer.FullName `
        -ArgumentList $Arguments `
        -PassThru `
        -ErrorAction Stop

    $Process.WaitForExit(900000) | Out-Null

    if (-not $Process.HasExited) {
        $Process.Kill()
        throw "Cài đặt Android Studio bị treo (Timeout 15 phút). Tiến trình đã bị ép đóng."
    }

    Write-Host "Exit Code : $($Process.ExitCode)"

    # Xử lý các Exit Code an toàn
    switch ($Process.ExitCode)
    {
        { $_ -in @(0, 1223) } 
        {
            Write-Host "`n===== INSTALL SUCCESS =====" -ForegroundColor Green
            if ($_ -eq 1223) {
                Write-Host "CẢNH BÁO (1223): Core IDE đã cài xong, nhưng tiến trình cấu hình SDK bị ngắt bởi Session 0 của Jenkins." -ForegroundColor Yellow
            }
            break
        }
        default 
        {
            throw "Android Studio cài đặt thất bại. Exit Code: $($Process.ExitCode)"
        }
    }
}
catch {
    Write-Host "LỖI HỆ THỐNG: $_" -ForegroundColor Red
    throw "Quá trình cài đặt bị gián đoạn."
}
