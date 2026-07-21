param(
    [string]$Software
)

$TargetFolder = "C:\It-Support\SCM"
$SourceFolder = "\\10.2.15.93\Setup\$Software"

Write-Host ""
Write-Host "===== DOWNLOAD ====="

Write-Host "Software : $Software"

if(!(Test-Path $SourceFolder))
{
    throw "Không tìm thấy $SourceFolder"
}

Get-ChildItem $TargetFolder -Force -ErrorAction SilentlyContinue |
Remove-Item -Force -Recurse

Copy-Item `
    "$SourceFolder\*" `
    $TargetFolder `
    -Recurse `
    -Force

Write-Host ""

Write-Host "Copied Files"

Get-ChildItem $TargetFolder -Recurse |
ForEach-Object{

    Write-Host $_.Name

}

Write-Host ""
Write-Host "===== DOWNLOAD SUCCESS ====="
