pipeline {
    agent any

pipeline {
    agent any

    options {
        timestamps()
    }

    // THÊM BLOCK PARAMETERS VÀO ĐÂY
    parameters {
        string(name: 'TARGET', defaultValue: '', description: 'Nhập thông tin máy đích (Ưu tiên: IP máy hoặc Hostname. Có thể nhập Username/MAC nếu hệ thống đã cấu hình script phân giải).')
        string(name: 'SOFTWARE', defaultValue: '', description: 'Nhập tên thư mục phần mềm (Ví dụ: Dbeaver, Greenshot...)')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "===== Source code đã được Jenkins checkout ====="
            }
        }

        stage('Prepare Folder on Target') {
            steps {
                echo "===== Prepare Folder on ${params.TARGET} ====="
                // Truyền thêm biến Target vào script
                powershell """
                    .\\scripts\\prepare.ps1 -Software '${params.SOFTWARE}' -Target '${params.TARGET}'
                """
            }
        }
        
        // ... Các stage cài đặt cũng sẽ nhận thêm -Target tương tự ...
    }
}
    
    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "===== Source code đã được Jenkins checkout ====="
            }
        }

        stage('Prepare Folder') {
            steps {
                echo "===== Prepare Folder ====="

                powershell """
                    .\\scripts\\prepare.ps1 -Software '${params.SOFTWARE}'
                """
            }
        }

        stage('Install Software') {
            steps {
                echo "===== Install Software ====="

                powershell """
                    .\\scripts\\install.ps1 -Software '${params.SOFTWARE}'
                """
            }
        }

        stage('Cleanup') {
            steps {
                echo "===== Cleanup ====="

                powershell '''
                    $Folder = "C:\\It-Support\\SCM"

                    if(Test-Path $Folder)
                    {
                        Get-ChildItem $Folder -Force |
                            Remove-Item -Recurse -Force

                        Write-Host ""
                        Write-Host "===== CLEANUP SUCCESS ====="
                    }
                    else
                    {
                        Write-Host "Folder not found."
                    }
                '''
            }
        }

    }

    post {
        success {
            echo "===== PIPELINE SUCCESS ====="
        }

        failure {
            echo "===== PIPELINE FAILED ====="
        }
    }
}
