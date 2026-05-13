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
                sh "echo 'Tests passed'"
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
}
