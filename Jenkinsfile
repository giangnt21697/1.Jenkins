pipeline {
    agent any

    options {
        timeout(time: 1, unit: 'HOURS')
        timestamps() 
    }

    stages {
        stage('Tải thư viện & Kiểm tra mạng') {
            options {
                retry(2)
                timeout(time: 2, unit: 'MINUTES')
            }
            steps {
                echo '=== ĐANG KIỂM TRA KẾT NỐI MẠNG ==='
                bat 'ping google.com -n 2'
            }
        }

        // STAGE MỚI: Chỉ chạy bước này nếu chạy trên nhánh chính (main)
        stage('Triển khai môi trường Thật (Production)') {
            when {
                branch 'main' // Điều kiện: Tên nhánh hiện tại phải là main
            }
            steps {
                echo '🚀 [CONDITIONAL] Thỏa mãn điều kiện nhánh main! Đang triển khai...'
                bat 'echo Da deploy thanh cong len Production Server.'
            }
        }
    }

    post {
        always {
            echo '=== BƯỚC DỌN DẸP HỆ THỐNG ==='
        }
        success {
            echo '🎉 [SUCCESS] Pipeline chạy hoàn hảo!'
        }
        failure {
            echo '❌ [FAILURE] Có lỗi xảy ra!'
        }
    }
}
