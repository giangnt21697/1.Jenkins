pipeline {
    agent any

    parameters {
        choice(
            name: 'SOFTWARE',
            choices: [
                '3CX'
            ],
            description: 'Select Software'
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

                powershell '''
                    .\\scripts\\prepare.ps1 -Software "${env:SOFTWARE}"
                '''
            }
        }

        stage('Install Software') {
            steps {
                echo "===== Install Software ====="

                powershell '''
                    .\\scripts\\install.ps1 -Software "${params.SOFTWARE}"
                '''
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
