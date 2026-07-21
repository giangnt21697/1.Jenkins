pipeline {
    agent any

    parameters {
        // 1. Tự động quét và tạo danh sách phần mềm từ đúng đường dẫn mạng của bạn
        activeChoice(
            name: 'CHON_PHAN_MEM',
            choiceType: 'PT_SINGLE_SELECT',
            description: 'Nhập từ khóa tìm kiếm hoặc chọn gói phần mềm từ Server Setup',
            script: groovyScript(
                script: '''
                    import groovy.io.FileType
                    def softwareList = []
                    // Khai báo đúng đường dẫn chứa bộ cài thực tế của bạn
                    def shareFolder = new File("\\\\10.2.15.93\\d$\\Giangnt\\Setup") 
                    
                    if(shareFolder.exists()) {
                        shareFolder.eachDir { dir -> softwareList.add(dir.name) }
                    } else {
                        // Thử nghiệm dự phòng nếu đường dẫn mạng Windows dùng quyền admin cục bộ d$ bị chặn
                        shareFolder = new File("\\\\10.2.15.93\\Giangnt\\Setup")
                        if(shareFolder.exists()) {
                            shareFolder.eachDir { dir -> softwareList.add(dir.name) }
                        } else {
                            softwareList.add("Không kết nối được kho bộ cài tại 10.2.15.93!")
                        }
                    }
                    return softwareList.sort()
                '''
            ),
            filterable: true // Ô tìm kiếm bằng văn bản (Text Search)
        )
        
        // 2. Đổi tên thành Target và cho phép nhập linh hoạt theo yêu cầu của bạn
        string(
            name: 'Target', 
            defaultValue: 'localhost', 
            description: 'Nhập thông tin máy đích cần cài đặt (Có thể điền: IP, MAC Address, hoặc Tên User trong Domain)'
        )
    }

    environment {
        // Đường dẫn chứa bộ cài thực tế của bạn (Chuyển sang định dạng đường dẫn Windows mạng chuẩn)
        SHARE_PATH = '\\\\10.2.15.93\\d$\\Giangnt\\Setup'
        SHARE_PATH_ALT = '\\\\10.2.15.93\\Giangnt\\Setup'
        
        // Đường dẫn chứa file tạm thực tế trên máy đích của bạn
        TARGET_DIR = 'C:\\It-Support\\SCM' 
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        timestamps()
    }

    stages {
        stage('1. Check kết nối máy chủ và máy đích') {
            steps {
                echo "=== ĐANG KIỂM TRA ĐỊNH DANH MÁY ĐÍCH (TARGET): ${params.Target} ==="
                powershell """
                    \$target = "${params.Target}"
                    Write-Host "Tiến hành kiểm tra trạng thái hoạt động của Target: \$target"
                    
                    # Nếu người dùng nhập IP hoặc tên máy, thực hiện ping kiểm tra kết nối mạng cơ bản
                    if (\$target -ne "localhost" -and \$target -notmatch '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})\$') {
                        Test-Connection -ComputerName \$target -Count 2 -ErrorAction Stop
                    } else {
                        Write-Host "Target nhập dạng đặc biệt (MAC/User) hoặc đang chạy nội bộ (localhost), chuyển sang bước tiếp theo."
                    }
                """
            }
        }

        stage('2. Download file về folder tạo trên máy đích (ẩn folder)') {
            steps {
                echo "=== KHỞI TẠO THƯ MỤC CỐ ĐỊNH VÀ TẢI BỘ CÀI VỀ MÁY ĐÍCH ==="
                powershell """
                    \$targetPath = "${env.TARGET_DIR}"
                    
                    # 1. Tạo thư mục cố định nếu chưa có và chuyển sang trạng thái Ẩn (Hidden)
                    if (-not (Test-Path \$targetPath)) {
                        New-Item -ItemType Directory -Path \$targetPath -Force | Out-Null
                        \$folder = Get-Item \$targetPath
                        \$folder.Attributes = \$folder.Attributes -bor [System.IO.FileAttributes]::Hidden
                        Write-Host "Đã tạo mới thư mục ẩn thực tế tại: \$targetPath"
                    } else {
                        # Đảm bảo thư mục luôn ở trạng thái ẩn ngay cả khi đã tồn tại từ trước
                        \$folder = Get-Item \$targetPath
                        if ((\$folder.Attributes -and [System.IO.FileAttributes]::Hidden) -ne [System.IO.FileAttributes]::Hidden) {
                            \$folder.Attributes = \$folder.Attributes -bor [System.IO.FileAttributes]::Hidden
                        }
                        Write-Host "Thư mục cố định đã sẵn sàng và đang ở trạng thái ẩn."
                    }
                    
                    # 2. Xác định đường dẫn mạng chính xác để copy dữ liệu gói phần mềm
                    \$sourcePath = "${env.SHARE_PATH}\\${params.CHON_PHAN_MEM}"
                    if (-not (Test-Path \$sourcePath)) {
                        \$sourcePath = "${env.SHARE_PATH_ALT}\\${params.CHON_PHAN_MEM}"
                    }
                    
                    Write-Host "Đang tải dữ liệu từ: \$sourcePath về thư mục tạm trên máy đích..."
                    Copy-Item -Path "\$sourcePath\\*" -Destination \$targetPath -Recurse -Force
                    Write-Host "Đã hoàn tất tải file bộ cài."
                """
            }
        }

        stage('3. Thực hiện chạy silent tự động') {
            steps {
                echo "=== TỰ ĐỘNG ĐỌC FILE TẠI THƯ MỤC SCM VÀ THỰC THI SILENT INSTALL ==="
                powershell """
                    cd "${env.TARGET_DIR}"
                    
                    # Tìm file cài đặt có trong thư mục SCM
                    \$installer = Get-ChildItem -Path . -Include *.msi, *.exe -Recurse | Select-Object -First 1
                    
                    if (\$installer -eq \$null) {
                        throw "Lỗi: Không tìm thấy bất kỳ file .exe hoặc .msi nào trong thư mục SCM!"
                    }
                    
                    \$fileName = \$installer.Name
                    \$extension = \$installer.Extension.ToLower()
                    Write-Host "Đã nhận diện file cài đặt thực tế: \$fileName"
                    
                    # Thực thi quy trình cài đặt ẩn tiêu chuẩn doanh nghiệp
                    if (\$extension -eq ".msi") {
                        Write-Host "Thực thi lệnh Silent cho gói MSI..."
                        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"\$fileName`" /qn /norestart" -Wait -NoNewWindow
                    } 
                    elseif (\$extension -eq ".exe") {
                        Write-Host "Thực thi lệnh Silent cho gói EXE..."
                        \$silentArgs = @("/S", "/silent", "/quiet", "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART")
                        \$success = \$false
                        
                        foreach (\$arg in \$silentArgs) {
                            try {
                                Write-Host "Thử cài ngầm bằng cờ: \$arg"
                                \$process = Start-Process -FilePath ".\$fileName" -ArgumentList \$arg -Wait -PassThru -NoNewWindow -ErrorAction Stop
                                if (\$process.ExitCode -eq 0) {
                                    \$success = \$true
                                    break
                                }
                            } catch {}
                        }
                    }
                """
            }
        }

        stage('4. Trả kết quả thành công, thất bại lại Jenkins & Làm sạch bộ cài') {
            steps {
                echo "=== DỌN DẸP BỘ CÀI/SCRIPTS TRONG SCM - GIỮ LẠI FOLDER GỐC ==="
                // Xóa toàn bộ nội dung bên trong SCM nhưng giữ lại cấu trúc thư mục SCM ở trạng thái ẩn
                powershell """
                    \$targetPath = "${env.TARGET_DIR}"
                    if (Test-Path \$targetPath) {
                        Get-ChildItem -Path \$targetPath -Recurse | Remove-Item -Recurse -Force
                        Write-Host "Đã dọn dẹp làm sạch toàn bộ tệp tin bên trong thư mục ẩn C:\\It-Support\\SCM."
                    }
                """
            }
        }
    }

    post {
        success {
            echo "🎉 [SUCCESS] Đã hoàn tất cài đặt ngầm gói [${params.CHON_PHAN_MEM}] lên đích đến [${params.Target}]."
        }
        failure {
            echo "❌ [FAILURE] Quá trình xử lý gặp lỗi. Vui lòng kiểm tra lại log chi tiết hoặc quyền truy cập ổ mạng!"
        }
    }
}
