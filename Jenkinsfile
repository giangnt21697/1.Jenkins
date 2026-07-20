pipeline {
    agent any
    
    // Khai báo các tham số đầu vào để người dùng lựa chọn khi bấm chạy
    parameters {
        choice(name: 'MOI_TRUONG', choices: ['Dev', 'Staging', 'Production'], description: 'Chọn môi trường để triển khai phần mềm')
        string(name: 'PHIEN_BAN', defaultValue: '1.0.0', description: 'Nhập số phiên bản ứng dụng')
    }

    stages {
        stage('Khởi tạo cấu hình') {
            steps {
                echo "=== BẮT ĐẦU QUY TRÌNH BUILD CHO MÔI TRƯỜNG: ${params.MOI_TRUONG} ==="
                echo "Phiên bản phần mềm dự kiến: ${params.PHIEN_BAN}"
            }
        }

        stage('Biên dịch ứng dụng') {
            steps {
                bat "echo Đang biên dịch ứng dụng bản ${params.PHIEN_BAN} cho môi trường ${params.MOI_TRUONG}..."
                
                // Tạo thư mục đóng gói phân biệt theo môi trường chọn
                bat "mkdir build_output_\\${params.MOI_TRUONG}"
                bat "echo Khởi tạo thành công bản ${params.PHIEN_BAN} > build_output_\\${params.MOI_TRUONG}\\app_v${params.PHIEN_BAN}.txt"
            }
        }

        stage('Lưu trữ sản phẩm') {
            steps {
                echo '=== ĐÓNG GÓI VÀ LƯU TRỮ PHẦN MỀM ==='
                // Tự động tìm và lưu trữ tất cả các file .txt trong thư mục vừa tạo
                archiveArtifacts artifacts: "build_output_\\${params.MOI_TRUONG}/*.txt", fingerprint: true
            }
        }
    }
}
