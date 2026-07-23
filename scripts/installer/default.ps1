# ============================================================
# DEFAULT INSTALLER - DYNAMIC DETECTION ENABLED (By Giang IT)
# ============================================================

param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

# ------------------------------------------------------------
# HÀM NHẬN DIỆN ENGINE (CORE LOGIC)
# ------------------------------------------------------------
function Get-SilentSwitch {
    param([System.IO.FileInfo]$File)

    $VersionInfo = $File.VersionInfo
    $MetaString = "$($VersionInfo.FileDescription) | $($VersionInfo.LegalCopyright) | $($VersionInfo.ProductName)"

    if ($MetaString -match "Inno Setup") {
        Write-Host " [ Engine ] Inno Setup" -ForegroundColor Cyan
        return "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
    }
    if ($MetaString -match "Nullsoft" -or $MetaString -match "NSIS") {
        Write-Host " [ Engine ] NSIS" -ForegroundColor Cyan
        return "/S"
    }
    if ($MetaString -match "InstallShield" -or $MetaString -match "Flexera") {
        Write-Host " [ Engine ] InstallShield" -ForegroundColor Cyan
        return "/s /v`"/qn /norestart`""
    }
    if ($MetaString -match "WiX Toolset" -or $MetaString -match "Burn") {
        Write-Host " [ Engine ] WiX Toolset" -ForegroundColor Cyan
        return "-quiet -norestart"
    }

    Write-Host " [ Engine ] Unknown" -ForegroundColor Yellow
    return $null
}

# ------------------------------------------------------------
# LOGIC CÀI ĐẶT CHÍNH
# ------------------------------------------------------------
Write-Host ""
Write-Host "===== START INSTALLATION ====="
Write-Host "Software  : $Software"

if ($null -eq $Installer) {
    throw "LỖI: Installer chưa được truyền vào default.ps1"
}

Write-Host "Installer : $($Installer.Name)"
Write-Host "Path      : $($Installer.FullName)`n"

switch ($Installer.Extension.ToLower())
{
    ".msi"
    {
        Write-Host "[+] Processing MSI Installer..."
        $Process = Start-Process `
            -FilePath "msiexec.exe" `
            -ArgumentList "/i `"$($Installer.FullName)`" /qn /norestart" `
            -Wait -PassThru

        Write-Host "Exit Code : $($Process.ExitCode)"

        # MSI có 3 mã thành công phổ biến
        $SuccessCodes = @(0, 1641, 3010)
        
        if ($Process.ExitCode -notin $SuccessCodes) {
            throw "MSI cài đặt thất bại. Vui lòng kiểm tra Event Viewer."
        }
        
        if ($Process.ExitCode -eq 3010 -or $Process.ExitCode -eq 1641) {
            Write-Host "CẢNH BÁO: Cần khởi động lại máy để hoàn tất!" -ForegroundColor Yellow
        }
        break
    }

    ".exe"
    {
        Write-Host "[+] Processing EXE Installer..."
        
        # Gọi hàm quét Metadata
        $SilentArg = Get-SilentSwitch -File $Installer

        # Xử lý trường hợp nhận diện được Engine
        if ($null -ne $SilentArg) {
            Write-Host "Applying Switch : $SilentArg" -ForegroundColor Green
            
            $Process = Start-Process `
                -FilePath $Installer.FullName `
                -ArgumentList $SilentArg `
                -Wait -PassThru

            Write-Host "Exit Code : $($Process.ExitCode)"

            if ($Process.ExitCode -ne 0 -and $Process.ExitCode -ne 3010) {
                Write-Host "Cảnh báo: Có lỗi xảy ra trong quá trình cài đặt (Exit Code: $($Process.ExitCode))" -ForegroundColor Red
            } else {
                Write-Host "Cài đặt thành công!" -ForegroundColor Green
            }
        }
        # Xử lý trường hợp Engine dị (Không nhận diện được)
        else {
            Write-Host "LỖI: Không thể nhận diện trình đóng gói." -ForegroundColor Red
            throw "Yêu cầu tạo file cấu hình riêng (Ví dụ: installer\$Software.ps1) cho phần mềm này."
        }
        break
    }

    default
    {
        throw "LỖI: Định dạng $($Installer.Extension) không được hỗ trợ."
    }
}

Write-Host "`n===== INSTALL SUCCESS ====="
