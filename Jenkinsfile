pipeline {
    agent any

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

                powershell '''
                    .\\scripts\\debug.ps1
                '''
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
