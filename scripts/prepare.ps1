$TargetFolder = "C:\It-Support\SCM"
$ShareFolder  = "\\10.2.15.93\Setup"

Write-Host "===== PREPARE FOLDER ====="

New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
attrib +h $TargetFolder

Write-Host "Target Folder : $TargetFolder"

if(Test-Path $ShareFolder)
{
    Write-Host "Share Connected."

    $Software = Get-ChildItem $ShareFolder -Directory

    Write-Host "Total Software : $($Software.Count)"

    $Software |
        Select-Object -First 5 |
        ForEach-Object{
            Write-Host " - $($_.Name)"
        }
}
else
{
    throw "Cannot access $ShareFolder"
}

Write-Host "===== DONE ====="
