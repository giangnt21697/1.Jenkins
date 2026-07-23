# ============================================================
# DEFAULT INSTALLER (Optimized by Giang IT)
# ============================================================

param(
    [string]$Software,
    [System.IO.FileInfo]$Installer
)

Write-Host ""
Write-Host "===== INSTALL ====="
Write-Host "Software  : $Software"
Write-Host "Installer : $($Installer.Name)"

if ($null -eq $Installer) {
    throw "Installer chưa được truyền vào default.ps1"
}

Write-Host "`nFound Installer"
Write-Host "Name      : $($Installer.Name)"
Write-Host "Extension : $($Installer.Extension)"
Write-Host "Full Path : $($Installer.FullName)`n"

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

        # Danh sách các Exit Code được coi là thành công của MSI
        $SuccessCodes = @(0, 1641, 3010)
        
        if ($Process.ExitCode -notin $SuccessCodes) {
            throw "MSI cài đặt thất bại với mã lỗi: $($Process.ExitCode). Vui lòng kiểm tra lại log."
        }
        
        if ($Process.ExitCode -eq 3010) {
            Write-Host "Cảnh báo: Phần mềm yêu cầu khởi động lại máy để hoàn tất!" -ForegroundColor Yellow
        }

        break
    }

    ".exe"
    {
        Write-Host "Installer Type : EXE"
        Write-Host "LƯU Ý: Đang dùng chế độ thử tham số (Brute-force). Có thể gây treo nếu installer mở giao diện GUI." -ForegroundColor Yellow

        $SilentArgs = @(
            "/S", "/s", "/silent", "/SILENT", "/quiet", 
            "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART", "/silent /install"
        )

        $Installed = $false

        foreach($Arg in $SilentArgs)
        {
            Write-Host "`nTrying : $Arg"
            
            try
            {
                # Sử dụng timeout 10 phút (600 giây) để chống treo script nếu GUI hiện lên
                $Process = Start-Process `
                    -FilePath $Installer.FullName `
                    -ArgumentList $Arg `
                    -PassThru `
                    -ErrorAction Stop

                $Process.WaitForExit(600000) | Out-Null

                # Nếu process chưa tắt sau 10 phút, buộc đóng và thử tham số khác
                if (-not $Process.HasExited) {
                    Write-Host "Process bị treo (Timeout). Đang dọn dẹp..." -ForegroundColor Red
                    $Process.Kill()
                    continue
                }

                Write-Host "Exit Code : $($Process.ExitCode)"

                if($Process.ExitCode -eq 0 -or $Process.ExitCode -eq 1223)
                {
                    Write-Host "Silent switch accepted: $Arg" -ForegroundColor Green
                    $Installed = $true
                    break
                }
            }
            catch
            {
                Write-Host "Failed to start process." -ForegroundColor Red
            }
        }

        if(-not $Installed)
        {
            throw "Không tìm được silent switch phù hợp hoặc quá trình cài đặt gặp lỗi."
        }

        break
    }

    default
    {
        throw "Không hỗ trợ định dạng $($Installer.Extension)"
    }
}

Write-Host "`n===== INSTALL SUCCESS =====" -ForegroundColor Green
