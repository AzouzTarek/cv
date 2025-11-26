
pipeline {
  agent any
  environment {
    DOCKERHUB_CRED = credentials('dockerhub-creds') // ID credential Jenkins
    DOCKER_IMAGE = "azouztarek/moncv" // remplacer
    GITOPS_TOKEN = credentials('gitops-token')
    SLACK_WEBHOOK = credentials('slack-webhook') // ou integration via plug>
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
          // ⚠️ Correction: retirer les &gt; et fermer correctement la chaîne
          sh "echo ${DOCKERHUB_CRED_PSW} | docker login -u ${DOCKERHUB_CRED_USR} --password-stdin"
          sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
          sh "docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
          sh "docker push ${DOCKER_IMAGE}:latest"
        }
      }
    }
  }

  /* -------------------------------
         🔥 GitOps : Update Manifests K8S
         -------------------------------- */
  stage('Update GitOps Manifests') {
    steps {
      script {
        // ⚠️ Correction: retirer les &gt; et chemins tronqués
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

  post {
    success {
      script {
        // Slack notify via webhook (simple curl)
        sh '''
          curl -X POST -H 'Content-type: application/json' --data '{
            "text": "Build ${env.BUILD_NUMBER} SUCCESS: ${env.JOB_NAME}"
          }' ${SLACK_WEBHOOK}
        '''
      }
    }
    failure {
      script {
        sh '''
          curl -X POST -H 'Content-type: application/json' --data '{
            "text": "Build ${env.BUILD_NUMBER} FAILED: ${env.JOB_NAME}"
          }' ${SLACK_WEBHOOK}
        '''
      }
    }
  }
}
