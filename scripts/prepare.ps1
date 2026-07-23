param(
    [string]$Software,
    [string]$Target
)

if ([string]::IsNullOrWhiteSpace($Target)) { throw "LỖI: Vui lòng nhập Target (IP hoặc Hostname) của máy đích." }

$ShareFolder  = "\\10.2.15.93\Setup"

# Đường dẫn mạng ẩn đến thẳng ổ C của máy Client
$RemoteFolder = "\\$Target\c$\It-Support\SCM"

Write-Host "`n===== PREPARE ON TARGET: $Target ====="
Write-Host "Software : $Software"

# 1. Tạo thư mục đích trên máy Target nếu chưa có
if (!(Test-Path $RemoteFolder)) {
    New-Item -ItemType Directory -Path $RemoteFolder -Force | Out-Null
}

# Xóa toàn bộ file cũ (đề phòng kẹt)
Get-ChildItem $RemoteFolder -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force

# 2. Copy Installer từ Share Server sang Target
$SourceFolder = Join-Path $ShareFolder $Software
Write-Host "`nSource Folder : $SourceFolder"

if (!(Test-Path $SourceFolder)) { throw "Không tìm thấy thư mục phần mềm: $SourceFolder" }

$Installer = Get-ChildItem -Path $SourceFolder -File -Include *.exe, *.msi | Select-Object -First 1
if ($null -eq $Installer) { throw "Không tìm thấy file .exe hoặc .msi trong $SourceFolder" }

Write-Host "Found Installer : $($Installer.Name)"
Copy-Item -Path $Installer.FullName -Destination $RemoteFolder -Force
Write-Host "-> Copied Installer to $Target"

# 3. Copy BỘ NÃO SCRIPT (thư mục scripts) từ Jenkins sang máy Target
# Điều này đảm bảo máy đích có file default.ps1 và CSV để tự đọc
$WorkspaceScripts = Join-Path $PWD "scripts"
Copy-Item -Path $WorkspaceScripts -Destination $RemoteFolder -Recurse -Force
Write-Host "-> Copied Deployment Scripts to $Target"

Write-Host "`n===== PREPARE SUCCESS ====="
