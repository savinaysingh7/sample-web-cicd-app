pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {
        stage('Git-Job') {
            steps {
                checkout scm
            }
        }

        stage('Build-Website') {
            steps {
                script {
                    sh 'echo "Building website source from Git commit..."'
                    sh 'test -f app.js'
                    sh 'grep -n "Webhook test" app.js'
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                // Simulating a random test outcome to show CI/CD gating
                sh '''
                if [ $((RANDOM % 2)) -eq 0 ]; then
                    echo "Tests failed! Oh no!"
                    exit 1
                else
                    echo "Tests passed!"
                fi
                '''
            }
        }

        stage('Deploy-Website') {
            steps {
                script {
                    sh 'mkdir -p /var/jenkins_home/deployments/sample-web-cicd-app'
                    sh 'cp app.js /var/jenkins_home/deployments/sample-web-cicd-app/app.js'
                    sh 'echo "Deployed app.js to /var/jenkins_home/deployments/sample-web-cicd-app"'
                }
            }
        }
    }
    
    post {
        always {
            echo "Pipeline finished execution."
        }
        success {
            echo "SUCCESS: Everything passed, and the website is deployed!"
        }
        failure {
            echo "FAILURE: Tests failed! Deployment has been blocked."
        }
    }
}
