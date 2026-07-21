pipeline {
    agent any

    // Cấu hình chung cho toàn bộ Pipeline
    options {
        timeout(time: 1, unit: 'HOURS') // Tổng thời gian chạy không quá 1 tiếng
        timestamps() // In thêm thời gian (giờ:phút:giây) vào đầu mỗi dòng Log
    }

    stages {
        stage('Tải thư viện & Kiểm tra mạng') {
            options {
                retry(3) // Nếu stage này lỗi, tự động chạy lại tối đa 3 lần
                timeout(time: 2, unit: 'MINUTES') // Stage này không được chạy quá 2 phút
            }
            steps {
                echo '=== ĐANG KIỂM TRA KẾT NỐI MẠNG ĐẾN SERVER MÔ PHỎNG ==='
                // Lệnh ping kiểm tra kết nối mạng trên Windows
                bat 'ping google.com -n 2'
            }
        }

        stage('Thực thi kịch bản chính') {
            steps {
                echo '=== ĐANG CHẠY CÁC CÂU LỆNH CHÍNH ==='
                bat 'echo Xin chao! Quy trinh dang dien ra on dinh.'
            }
        }
    }

    // Luôn luôn chạy sau khi các stage kết thúc (Dọn dẹp hệ thống)
    post {
        always {
            echo '=== BƯỚC DỌN DẸP HỆ THỐNG (ALWAYS RUN) ==='
            echo 'Đang xóa các file tạm và giải phóng bộ nhớ trên Windows...'
        }
        success {
            echo '🎉 [SUCCESS] Mọi thứ chạy hoàn hảo!'
        }
        failure {
            echo '❌ [FAILURE] Pipeline bị lỗi ở một bước nào đó, hãy kiểm tra lại!'
        }
    }
}
