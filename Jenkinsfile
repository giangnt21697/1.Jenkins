pipeline {
    agent any
    
    parameters {
    string(
        name: 'SOFTWARE',
        defaultValue: '3CX',
        description: 'Tên thư mục phần mềm trong \\\\10.2.15.93\\Setup'
    )
}
    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                echo "===== Source code đã được Jenkins checkout ====="
            }
        }

        stage('Run Debug Script') {
            steps {
                echo "===== Chạy scripts/debug.ps1 ====="

                powershell """
    .\\scripts\\prepare.ps1

    .\\scripts\\download.ps1 `
        -Software "${params.SOFTWARE}"
"""
            }
        }

    }

    post {

        success {
            echo "===== DEBUG SUCCESS ====="
        }

        failure {
            echo "===== DEBUG FAILED ====="
        }

    }
}
