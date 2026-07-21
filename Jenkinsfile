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
                checkout scm
                echo "===== Source code đã được Jenkins checkout ====="
            }
        }

        stage('Prepare Folder') {
            steps {
                echo "===== Prepare Folder ====="

                powershell """
                    .\\scripts\\prepare.ps1 -Software "${params.SOFTWARE}"
                """
            }
        }

        stage('Install Software') {
            steps {
                echo "===== Install Software ====="

                powershell """
                    .\\scripts\\install.ps1 -Software "${params.SOFTWARE}"
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
