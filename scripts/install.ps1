param(
    [string]$Software
)

# ============================================================
# INSTALL.PS1
#
# Chức năng:
# 1. Nhận tên phần mềm từ Jenkins
# 2. Tìm bộ cài đã được prepare.ps1 copy về
# 3. Nếu có script riêng -> chạy script riêng
# 4. Nếu không có -> chạy installer/default.ps1
#
# File này KHÔNG chứa logic cài đặt.
# Nó chỉ đóng vai trò Dispatcher.
# ============================================================

$TargetFolder = "C:\It-Support\SCM"

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host ""
Write-Host "Software : $Software"

# ============================================================
# Tìm bộ cài trong thư mục SCM.
# Theo thiết kế hiện tại Prepare chỉ copy đúng 1 installer,
# nên chỉ cần lấy file đầu tiên.
# ============================================================

$Installer = Get-ChildItem `
    -Path $TargetFolder `
    -File |
    Where-Object {
        $_.Extension -in ".exe", ".msi"
    } |
    Select-Object -First 1

if ($null -eq $Installer)
{
    throw "Không tìm thấy installer trong $TargetFolder"
}

Write-Host ""
Write-Host "Found Installer"
Write-Host "Name      : $($Installer.Name)"
Write-Host "Extension : $($Installer.Extension)"
Write-Host "Full Path : $($Installer.FullName)"
Write-Host ""

# ============================================================
# Kiểm tra xem phần mềm có script riêng hay không.
#
# Ví dụ:
# installer\Android_Studio.ps1
# installer\Office.ps1
#
# Nếu tồn tại:
#      -> chạy script riêng.
#
# Nếu không:
#      -> chạy default.ps1
# ============================================================

$CustomInstaller = Join-Path `
    $PSScriptRoot `
    "installer\$Software.ps1"

if(Test-Path $CustomInstaller)
{
    Write-Host "Using Custom Installer"
    Write-Host $CustomInstaller
    Write-Host ""

    & $CustomInstaller `
        -Software $Software `
        -Installer $Installer
}
else
{
    Write-Host "Using Default Installer"
    Write-Host ""

    & "$PSScriptRoot\installer\default.ps1" `
        -Software $Software `
        -Installer $Installer
}

Write-Host ""
Write-Host "===== INSTALL SUCCESS ====="
