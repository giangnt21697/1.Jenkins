param(
    [string]$Software
)

$TargetFolder = "C:\It-Support\SCM"

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host ""
Write-Host "Software : $Software"

# Tìm đúng file installer theo tên phần mềm được chọn
$Installer = Get-ChildItem `
    -Path $TargetFolder `
    -Recurse `
    -Include *.msi, *.exe |
    Where-Object {
        $_.BaseName -like "*$Software*"
    } |
    Select-Object -First 1

if ($null -eq $Installer)
{
    throw "Không tìm thấy installer cho phần mềm: $Software"
}

Write-Host ""
Write-Host "Found Installer"
Write-Host "Name      : $($Installer.Name)"
Write-Host "Extension : $($Installer.Extension)"
Write-Host "Full Path : $($Installer.FullName)"
Write-Host ""

switch ($Installer.Extension.ToLower())
{
    ".msi"
    {
        Write-Host "Installer Type : MSI"
        Write-Host "Start Installing..."

        $Process = Start-Process `
            -FilePath "msiexec.exe" `
            -ArgumentList "/i `"$($Installer.FullName)`" /qn /norestart" `
            -Wait `
            -PassThru

        Write-Host "Exit Code : $($Process.ExitCode)"

        if($Process.ExitCode -ne 0)
        {
            throw "MSI cài đặt thất bại."
        }

        break
    }

    ".exe"
    {
        Write-Host "Installer Type : EXE"

        $SilentArgs = @(
            "/S",
            "/s",
            "/silent",
            "/SILENT",
            "/quiet",
            "/VERYSILENT",
            "/verysilent",
            "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART",
            "/silent /install"
        )

        $Installed = $false

        foreach($Arg in $SilentArgs)
        {
            Write-Host ""
            Write-Host "Trying : $Arg"

            try
            {
                $Process = Start-Process `
                    -FilePath $Installer.FullName `
                    -ArgumentList $Arg `
                    -Wait `
                    -PassThru `
                    -ErrorAction Stop

                Write-Host "Exit Code : $($Process.ExitCode)"

                if($Process.ExitCode -eq 0)
                {
                    Write-Host "Silent switch accepted."
                    $Installed = $true
                    break
                }
            }
            catch
            {
                Write-Host "Failed."
            }
        }

        if(-not $Installed)
        {
            throw "Không tìm được silent switch phù hợp."
        }

        break
    }

    default
    {
        throw "Không hỗ trợ định dạng $($Installer.Extension)"
    }
}

Write-Host ""
Write-Host "===== INSTALL SUCCESS ====="
