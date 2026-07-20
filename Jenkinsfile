pipeline {
    agent any

    // Định nghĩa biến môi trường an toàn lấy từ kho bảo mật của Jenkins
    environment {
        // Lấy chuỗi bí mật có ID là 'MY_SECRET_KEY' gán vào biến bí mật trong Pipeline
        DB_PASSWORD = credentials('MY_SECRET_KEY')
    }

    stages {
        stage('Xử lý dữ liệu an toàn') {
            steps {
                echo '=== BẮT ĐẦU KẾT NỐI CƠ SỞ DỮ LIỆU ==='
                
                // Sử dụng biến môi trường an toàn trong lệnh Windows bat
                // Chú ý: Với lệnh bat trên Windows, biến môi trường phải được bọc trong dấu % (Ví dụ: %DB_PASSWORD%)
                bat 'echo Đang sử dụng mật khẩu bảo mật để kết nối: %DB_PASSWORD%'
            }
        }
    }
}
