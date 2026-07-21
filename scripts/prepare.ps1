$TargetFolder = "C:\It-Support\SCM"

Write-Host "===== PREPARE ====="

New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

attrib +h $TargetFolder

Write-Host "Target Folder : $TargetFolder"

Write-Host "===== PREPARE SUCCESS ====="
