pipeline {
    agent any

    // 1. Quản lý biến môi trường tập trung
    environment {
        APP_NAME = 'MyWindowsApp'
        DEPLOY_DIR = 'C:\\Deployments\\MyWindowsApp'
        TARGET_BRANCH = 'main'
    }

    // 2. Kiểm soát luồng chạy và thời gian toàn cục
    options {
        timeout(time: 30, unit: 'MINUTES') // Toàn bộ kịch bản không quá 30 phút
        timestamps() // Bật ghi nhận thời gian cho mọi stage
    }

    stages {
        stage('Khởi tạo & Kiểm tra mạng') {
            options {
                retry(2) // Tự động thử lại tối đa 2 lần nếu lỗi mạng
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

        // 3. Stage chạy có điều kiện nâng cao
        stage('Triển khai hệ thống (Deploy)') {
            when {
                // Kiểm tra nếu nhánh hiện tại trùng với TARGET_BRANCH đã khai báo ở trên
                expression { return env.BRANCH_NAME == env.TARGET_BRANCH || bat(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim() == env.TARGET_BRANCH }
            }
            steps {
                echo "🚀 [DEPLOY] Thỏa mãn điều kiện nhánh ${env.TARGET_BRANCH}!"
                echo "Đang triển khai sản phẩm vào thư mục: ${env.DEPLOY_DIR}"
                bat "echo Dang sao chep file vao thu muc ${env.DEPLOY_DIR}..."
            }
        }
    }

    // 4. Xử lý trạng thái sau khi kết thúc pipeline
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
