pipeline {
    agent any

    environment {
        APP_NAME = 'MyWindowsApp'
        DEPLOY_DIR = 'C:\\Deployments\\MyWindowsApp'
        TARGET_BRANCH = 'main'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        timestamps() 
    }

    stages {
        stage('Khởi tạo & Kiểm tra mạng') {
            options {
                retry(2) 
                timeout(time: 2, unit: 'MINUTES')
            }
            steps {
                echo "=== KÍCH HOẠT TIẾN TRÌNH CHO ỨNG DỤNG: ${env.APP_NAME} ==="
                bat 'ping google.com -n 2'
            }
        }

        stage('Kiểm tra mã nguồn (SCA)') {
            steps {
                echo '=== ĐANG QUÉT LỖI BẢO MẬT MÃ NGUỒN MÔ PHỎNG ==='
                bat 'echo Quet ma nguon hoan tat. Khong phat hien lo hong.'
            }
        }

        stage('Đóng gói ứng dụng') {
            steps {
                echo '=== ĐANG ĐÓNG GÓI SẢN PHẨM (BUILD ARTIFACT) ==='
                bat 'echo Da dong goi thanh cong file MyWindowsApp.zip'
            }
        }

        stage('Triển khai hệ thống (Deploy)') {
            when {
                // Sửa đổi: Sử dụng đường dẫn Git tuyệt đối để tránh lỗi môi trường Windows
                expression { 
                    return env.BRANCH_NAME == env.TARGET_BRANCH || 
                    bat(script: '"C:\\Program Files\\Git\\bin\\git.exe" rev-parse --abbrev-ref HEAD', returnStdout: true).trim() == env.TARGET_BRANCH 
                }
            }
            steps {
                echo "🚀 [DEPLOY] Thỏa mãn điều kiện nhánh ${env.TARGET_BRANCH}!"
                echo "Đang triển khai sản phẩm vào thư mục: ${env.DEPLOY_DIR}"
                bat "echo Dang sao chep file vao thu muc ${env.DEPLOY_DIR}..."
            }
        }
    }

    post {
        always {
            echo '=== BƯỚC DỌN DẸP HỆ THỐNG VÀ GIẢI PHÓNG BỘ NHỚ ==='
            echo "Hoàn tất xử lý cho ứng dụng: ${env.APP_NAME}"
        }
        success {
            echo '🎉 [SUCCESS] Hệ thống đã Build và Deploy thành công, không có lỗi!'
        }
        failure {
            echo '❌ [FAILURE] Quá trình xử lý gặp lỗi. Vui lòng kiểm tra lại cấu hình hoặc kết nối mạng!'
        }
    }
}
