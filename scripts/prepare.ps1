param(
    [string]$Software,
    [string]$Target
)

if ([string]::IsNullOrWhiteSpace($Target)) { throw "LỖI: Vui lòng nhập Target (IP hoặc Hostname) của máy đích." }

$ShareFolder  = "\\10.2.15.93\Setup"
$RemoteFolder = "\\$Target\c$\It-Support\SCM"

Write-Host "`n===== PREPARE ON TARGET: $Target ====="
Write-Host "Software : $Software"

if (!(Test-Path $RemoteFolder)) {
    New-Item -ItemType Directory -Path $RemoteFolder -Force | Out-Null
}

Get-ChildItem $RemoteFolder -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force

$SourceFolder = Join-Path $ShareFolder $Software
Write-Host "`nSource Folder : $SourceFolder"

if (!(Test-Path $SourceFolder)) { throw "Không tìm thấy thư mục phần mềm: $SourceFolder" }

# [ĐÃ FIX BUG] Dùng Where-Object thay vì -Include để tìm file chuẩn xác 100%
$Installer = Get-ChildItem -Path $SourceFolder -File | Where-Object { $_.Extension -in @(".exe", ".msi") } | Select-Object -First 1

if ($null -eq $Installer) { throw "Không tìm thấy file .exe hoặc .msi trong $SourceFolder" }

Write-Host "Found Installer : $($Installer.Name)"
Copy-Item -Path $Installer.FullName -Destination $RemoteFolder -Force
Write-Host "-> Copied Installer to $Target"

$WorkspaceScripts = Join-Path $PWD "scripts"
Copy-Item -Path $WorkspaceScripts -Destination $RemoteFolder -Recurse -Force
Write-Host "-> Copied Deployment Scripts to $Target"

Write-Host "`n===== PREPARE SUCCESS ====="
