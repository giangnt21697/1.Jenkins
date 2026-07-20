pipeline {
    agent any

    stages {
        stage('Môi trường Windows') {
            steps {
                echo '=== KIỂM TRA THÔNG TIN HỆ THỐNG WINDOWS ==='
                bat 'systeminfo | findstr /B /C:"OS Name" /C:"OS Version"'
                bat 'echo Thư mục làm việc hiện tại: %CD%'
            }
        }

        stage('Biên dịch & Xây dựng') {
            steps {
                echo '=== ĐANG GIẢ LẬP QUÁ TRÌNH BIÊN DỊCH ỨNG DỤNG ==='
                // Tại đây bạn có thể thay bằng lệnh thực tế như: npm run build, mvn clean package, dotnet build
                bat 'echo Đang biên dịch mã nguồn...'
                bat 'mkdir build_output'
                bat 'echo "Phần mềm phiên bản 1.0.0" > build_output\\app.exe'
            }
        }

        stage('Đóng gói sản phẩm') {
            steps {
                echo '=== LƯU TRỮ SẢN PHẨM SAU KHI BUILD THÀNH CÔNG ==='
                // Jenkins sẽ tự động lưu lại tệp app.exe này trực tiếp trên giao diện Web để bạn tải về
                archiveArtifacts artifacts: 'build_output/*.exe', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '🎉 Chúc mừng! Quy trình CI/CD hoàn tất thành công xuất sắc.'
        }
        failure {
            echo '❌ Lỗi xảy ra! Vui lòng kiểm tra lại mã nguồn hoặc mã script lệnh bat.'
        }
    }
}
