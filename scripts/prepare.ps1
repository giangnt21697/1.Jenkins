$TargetFolder = "C:\It-Support\SCM"

Write-Host "===== PREPARE FOLDER ====="

# Luôn tạo lại, nếu đã có thì không báo lỗi
New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null

# Đặt thuộc tính Hidden
attrib +h $TargetFolder

Write-Host "Folder:"
Resolve-Path $TargetFolder

Write-Host "Done."
