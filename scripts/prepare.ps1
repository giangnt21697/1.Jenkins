param(
    [string]$Software
)

$ShareFolder  = "\\10.2.15.93\Setup"
$TargetFolder = "C:\It-Support\SCM"

Write-Host ""
Write-Host "===== PREPARE ====="
Write-Host ""

Write-Host "Software : $Software"

# Tạo thư mục đích nếu chưa có
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

attrib +h $TargetFolder

# Xóa toàn bộ file cũ
Get-ChildItem $TargetFolder -Force -ErrorAction SilentlyContinue |
    Remove-Item -Recurse -Force

# Thư mục phần mềm được chọn
$SourceFolder = Join-Path $ShareFolder $Software

Write-Host ""
Write-Host "Source Folder : $SourceFolder"

if (!(Test-Path $SourceFolder))
{
    throw "Không tìm thấy thư mục phần mềm: $SourceFolder"
}

# Chỉ lấy file cài đặt đầu tiên
$Installer = Get-ChildItem `
    -Path $SourceFolder `
    -Filter *.exe `
    -File |
    Select-Object -First 1

if ($null -eq $Installer)
{
    $Installer = Get-ChildItem `
        -Path $SourceFolder `
        -Filter *.msi `
        -File |
        Select-Object -First 1
}

if ($null -eq $Installer)
{
    throw "Không tìm thấy file .exe hoặc .msi trong $SourceFolder"
}

Write-Host ""
Write-Host "Found Installer : $($Installer.Name)"

# Chỉ copy đúng file cài đặt
Copy-Item `
    -Path $Installer.FullName `
    -Destination $TargetFolder `
    -Force

Write-Host ""
Write-Host "Copied File"

Get-ChildItem $TargetFolder |
    Select Name, Length

Write-Host ""
Write-Host "===== PREPARE SUCCESS ====="
