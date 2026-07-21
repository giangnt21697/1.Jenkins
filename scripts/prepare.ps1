$TargetFolder = "C:\It-Support\SCM"
$SourceFolder = "\\10.2.15.93\Setup\3CX"

Write-Host "===== DOWNLOAD TEST ====="

New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
attrib +h $TargetFolder

# Xóa file cũ (không xóa folder)
Get-ChildItem $TargetFolder -Force -ErrorAction SilentlyContinue |
    Remove-Item -Force -Recurse

Write-Host "Copy từ:"
Write-Host $SourceFolder

Copy-Item `
    -Path "$SourceFolder\*" `
    -Destination $TargetFolder `
    -Recurse `
    -Force

Write-Host ""

Write-Host "Các file đã copy:"

Get-ChildItem $TargetFolder -Recurse | ForEach-Object{
    Write-Host $_.FullName
}

Write-Host ""
Write-Host "===== DOWNLOAD SUCCESS ====="
