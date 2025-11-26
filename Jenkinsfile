
pipeline {
  agent any

  environment {
    // Credentials Jenkins (type: Username with password)
    DOCKERHUB_CRED = credentials('dockerhub-creds')
    GITOPS_TOKEN   = credentials('gitops-token')      // token personnel/robot
    SLACK_WEBHOOK  = credentials('slack-webhook')     // secret webhook URL
    // Image Docker
    DOCKER_IMAGE   = "azouztarek/moncv"
  }

  // Poll SCM toutes les 5 min
  triggers {
    pollSCM('H/5 * * * *')
  }

  stages {
    stage('Checkout') {
      steps {
        // Clone explicite (branche main) du dépôt CV
        git branch: 'main', url: 'https://github.com/AzouzTarek/cv.git'
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          sh "docker --version"
          // Contexte de build sur ./cv (adapté si le Dockerfile est dans ce dossier)
          sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
        }
      }
    }

    stage('Login and Push') {
      steps {
        script {
          // Login DockerHub en stdin
          sh "echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin"

          // Tag latest + push
          sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
          sh "docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          sh "docker push ${DOCKER_IMAGE}:latest"
        }
      }
    }

    /* -------------------------------
           🔥 GitOps : Update Manifests K8S
       -------------------------------- */
    stage('Update GitOps Manifests') {
      steps {
        script {
          // Clonage du repo GitOps et mise à jour de l'image
          sh """
            rm -rf gitops
            git clone https://${GITOPS_TOKEN}@github.com/AzouzTarek/k8s.git gitops
            cd gitops

            # Mise à jour automatique de l'image dans deployment.yaml
            sed -i 's|image: .*|image: ${DOCKER_IMAGE}:${BUILD_NUMBER}|g' deployment.yaml

            git config user.email "jenkins@local"
            git config user.name "Jenkins CI"

            git add deployment.yaml
            git commit -m "Update image to ${DOCKER_IMAGE}:${BUILD_NUMBER}" || echo "No changes to commit"
            git push
          """
        }
      }
    }
  } // <= fin du bloc stages

  post {
    success {
      script {
        sh '''
          curl -X POST -H 'Content-type: application/json' --data '{
            "text": "✅ Build '${BUILD_NUMBER}' SUCCESS: '${JOB_NAME}'"
          }' '"${SLACK_WEBHOOK}"'
        '''
      }
    }
    failure {
      script {
        sh '''
          curl -X POST -H 'Content-type: application/json' --data '{
            "text": "❌ Build '${BUILD_NUMBER}' FAILED: '${JOB_NAME}'"
          }' '"${SLACK_WEBHOOK}"'
        '''
      }
    }
  }
}
