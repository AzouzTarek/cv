pipeline {
  agent any
  environment {
    DOCKERHUB_CRED = credentials('dockerhub-creds') // ID credential Jenkins
    DOCKER_IMAGE = "azouztarek/moncv" // remplacer
    SLACK_WEBHOOK = credentials('slack-webhook') // ou integration via plugin
  }
  triggers {
    pollSCM('H/5 * * * *') // every 5 minutes
  }

  stages {
    stage('Checkout') {
      steps {
        // Récupération explicite du code depuis GitHub
        git branch: 'main', url: 'https://github.com/AzouzTarek/cv.git'
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          sh "docker --version"
          sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ./cv"
        }
      }
    }

    stage('Login and Push') {
      steps {
        script {
          sh "echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin"
          sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
          sh "docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          sh "docker push ${DOCKER_IMAGE}:latest"
        }
      }
    }
  }

  post {
    success {
      script {
        // Slack notify via webhook (simple curl)
        sh '''
          curl -X POST -H 'Content-type: application/json' --data "{
            \\"text\\": \\"Build ${env.BUILD_NUMBER} SUCCESS: ${env.JOB_NAME}\\"
          }" ${SLACK_WEBHOOK}
        '''
      }
    }
    failure {
      script {
        sh '''
          curl -X POST -H 'Content-type: application/json' --data "{
            \\"text\\": \\"Build ${env.BUILD_NUMBER} FAILED: ${env.JOB_NAME}\\"
          }" ${SLACK_WEBHOOK}
        '''
      }
    }
  }
}
