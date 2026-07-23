pipeline {
    agent any

    options {
        timestamps()
    }

    // Giao diện nhập liệu khi bấm "Build with Parameters"
    parameters {
        string(name: 'TARGET', defaultValue: '', description: 'Nhập thông tin máy đích (Ưu tiên: IP máy hoặc Hostname).')
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
                powershell """
                    .\\scripts\\prepare.ps1 -Software '${params.SOFTWARE}' -Target '${params.TARGET}'
                """
            }
        }

        stage('Install Software on Target') {
            steps {
                echo "===== Install Software on ${params.TARGET} ====="
                powershell """
                    .\\scripts\\install.ps1 -Software '${params.SOFTWARE}' -Target '${params.TARGET}'
                """
            }
        }

        stage('Cleanup on Target') {
            steps {
                echo "===== Cleanup on ${params.TARGET} ====="
                // Dọn dẹp từ xa thông qua đường dẫn mạng ẩn SMB (\\IP\c$)
                powershell """
                    \$Target = '${params.TARGET}'
                    \$RemoteFolder = "\\\\\$Target\\c\$\\It-Support\\SCM"
                    
                    if(Test-Path \$RemoteFolder) {
                        Get-ChildItem \$RemoteFolder -Force | Remove-Item -Recurse -Force
                        Write-Host ""
                        Write-Host "===== CLEANUP SUCCESS ON \${Target} ====="
                    } else {
                        Write-Host "Folder not found on target."
                    }
                """
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
