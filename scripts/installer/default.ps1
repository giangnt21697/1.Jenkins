# ============================================================
# HYBRID DEPLOYMENT SCRIPT (CSV Centralized + Dynamic Detection)
# ============================================================

param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

Write-Host "`n===== START DEPLOYMENT ====="
Write-Host "Software  : $Software"
Write-Host "Installer : $($Installer.Name)"

if ($null -eq $Installer -or -not $Installer.Exists) {
    throw "LỖI: Không tìm thấy file Installer cho $Software."
}

# 1. Đọc file cấu hình CSV (nếu có)
$CsvPath = Join-Path -Path $PSScriptRoot -ChildPath "SilentSwitches.csv"
$Config = $null
if (Test-Path $CsvPath) {
    $CsvData = Import-Csv -Path $CsvPath -Encoding UTF8
    # Tìm dòng có SoftwareName khớp với tham số truyền vào
    $Config = $CsvData | Where-Object { $_.SoftwareName -eq $Software } | Select-Object -First 1
}

# 2. Hàm Quét Nhận Diện Động (Dành cho EXE không có trong CSV)
function Get-DynamicSwitch {
    param([System.IO.FileInfo]$File)
    $VersionInfo = $File.VersionInfo
    $Meta = "$($VersionInfo.FileDescription) | $($VersionInfo.LegalCopyright) | $($VersionInfo.ProductName)"
    
    if ($Meta -match "Inno Setup") { return "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART" }
    if ($Meta -match "Nullsoft|NSIS") { return "/S" }
    if ($Meta -match "InstallShield|Flexera") { return "/s /v`"/qn /norestart`"" }
    if ($Meta -match "WiX Toolset|Burn") { return "-quiet -norestart" }
    return $null
}

# 3. Xác định Tham Số Cài Đặt
$Executable = ""
$Arguments = ""
$SuccessCodes = @(0, 3010, 1641) # Các mã lỗi mặc định an toàn

if ($Installer.Extension.ToLower() -eq ".msi") {
    Write-Host "Type      : MSI Installer"
    $Executable = "msiexec.exe"
    $Arguments = "/i `"$($Installer.FullName)`" /qn /norestart"
    
    # Nếu MSI có cấu hình ghi đè trong CSV (Ví dụ cần thêm tham số riêng biệt)
    if ($null -ne $Config -and -not [string]::IsNullOrWhiteSpace($Config.SilentSwitch)) {
        $Arguments = $Config.SilentSwitch.Replace("[FILE]", "`"$($Installer.FullName)`"")
        Write-Host "Source    : CSV Configuration Override (MSI)" -ForegroundColor Cyan
    }
}
elseif ($Installer.Extension.ToLower() -eq ".exe") {
    Write-Host "Type      : EXE Installer"
    $Executable = $Installer.FullName

    # Ưu tiên 1: Lấy cấu hình từ file CSV
    if ($null -ne $Config -and -not [string]::IsNullOrWhiteSpace($Config.SilentSwitch)) {
        Write-Host "Source    : Centralized CSV Config" -ForegroundColor Cyan
        $Arguments = $Config.SilentSwitch
        
        # Ghi đè Success Code nếu CSV có khai báo (vd: 0,1223,3010 của Android Studio)
        if (-not [string]::IsNullOrWhiteSpace($Config.SuccessCodes)) {
            $SuccessCodes = $Config.SuccessCodes -split "," | ForEach-Object { [int]::Parse($_.Trim()) }
        }
    }
    # Ưu tiên 2: Dò tự động qua Metadata (Nếu app mới chưa kịp thêm vào CSV)
    else {
        $DynamicSwitch = Get-DynamicSwitch -File $Installer
        if ($null -ne $DynamicSwitch) {
            Write-Host "Source    : Dynamic Detection (Metadata)" -ForegroundColor Cyan
            $Arguments = $DynamicSwitch
        }
        # Ưu tiên 3: Báo lỗi an toàn
        else {
            Write-Host "LỖI: Không nhận diện được Engine cài đặt và cũng không tìm thấy trong CSV." -ForegroundColor Red
            throw "Vui lòng mở file SilentSwitches.csv và khai báo [$Software] kèm tham số cài đặt ẩn."
        }
    }
}
else {
    throw "LỖI: Định dạng $($Installer.Extension) không được hỗ trợ."
}

# 4. Thực thi Cài Đặt
Write-Host "Applying  : $Arguments" -ForegroundColor Yellow

try {
    # Timeout mặc định là 15 phút (900,000 ms)
    $Process = Start-Process `
        -FilePath $Executable `
        -ArgumentList $Arguments `
        -PassThru `
        -Wait `
        -ErrorAction Stop

    Write-Host "Exit Code : $($Process.ExitCode)"

    if ($Process.ExitCode -notin $SuccessCodes) {
        throw "$Software cài đặt thất bại. Exit Code: $($Process.ExitCode). Vui lòng kiểm tra Log hệ thống."
    }

    Write-Host "`n===== INSTALL SUCCESS =====" -ForegroundColor Green
    
    if ($Process.ExitCode -in @(3010, 1641)) {
        Write-Host "CẢNH BÁO: Hệ thống yêu cầu khởi động lại máy (Restart) để hoàn tất $Software!" -ForegroundColor Yellow
    }
    if ($Process.ExitCode -eq 1223) {
        Write-Host "CẢNH BÁO (1223): Phần chính đã cài xong, tiến trình phụ bị ngắt (Đặc trưng Bootstrapper)." -ForegroundColor Yellow
    }
} catch {
    Write-Host "LỖI HỆ THỐNG: $_" -ForegroundColor Red
    throw "Quá trình cài đặt bị gián đoạn."
}
