param(
    [string]$Software
)

$ShareFolder  = "\\10.2.15.93\Setup"
$TargetFolder = "C:\It-Support\SCM"

Write-Host ""
Write-Host "===== PREPARE ====="
Write-Host ""

Write-Host "Software : $Software"

New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

attrib +h $TargetFolder

Get-ChildItem $TargetFolder -Force |
    Remove-Item -Recurse -Force

$Source = Join-Path $ShareFolder $Software

Write-Host ""
Write-Host "Source : $Source"

if(!(Test-Path $Source))
{
    throw "Không tìm thấy thư mục phần mềm: $Source"
}

Copy-Item `
    "$Source\*" `
    $TargetFolder `
    -Recurse `
    -Force

Write-Host ""
Write-Host "Copied Files"

Get-ChildItem $TargetFolder -Recurse |
    Select Name

Write-Host ""
Write-Host "===== PREPARE SUCCESS ====="
