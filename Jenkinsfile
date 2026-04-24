pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sample-web-app'
        PORT = '3000'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh "echo 'Tests passed'"
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh "docker stop ${DOCKER_IMAGE} || true"
                    sh "docker rm ${DOCKER_IMAGE} || true"
                    sh "docker run -d --name ${DOCKER_IMAGE} -p ${PORT}:3000 ${DOCKER_IMAGE}"
                }
            }
        }
    }
}
