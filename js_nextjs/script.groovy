pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'jenkins-github-login' ,url: 'https://github.com/nathanvo1489/devops_04_nhat.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t nathanvo1489/js_nextjs_image:latest ./js_nextjs'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId:'jenkins-docker-login',
                    usernameVariable:'DOCKER_USER', passwordVariable:'DOCKER_PASS')
                ]) {
                    sh 'docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}'
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                sh '''
                    docker push nathanvo1489/js_nextjs_image:latest
                '''
            }
        }

        // stage('Deploy Container') {
        //     steps {
        //         sh'''
        //             docker rm js_nextjs -f || true
        //             docker run --name js_nextjs -d -p 3001:3000 js_nextjs_image
        //         '''
        //     }
        // }
    }
}