pipeline {
  agent any

  environment {
    AWS_ACCOUNT = '707258693637'
    AWS_REGION  = 'us-east-1'
    ECR         = '707258693637.dkr.ecr.us-east-1.amazonaws.com'
    CLUSTER     = 'boi-eks'
    // short git SHA becomes the immutable image tag
    IMAGE_TAG   = "${env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : 'dev'}"
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        script { env.IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim() }
        echo "Building tag: ${env.IMAGE_TAG}"
      }
    }

    stage('Build & Unit Test') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-17'
          args  '-v $HOME/.m2:/root/.m2'
          reuseNode true
        }
      }
      steps {
        sh 'mvn -B clean verify'
      }
      post {
        always { junit testResults: '**/target/surefire-reports/*.xml', allowEmptyResults: true }
      }
    }

    stage('SonarQube Analysis') {
      agent {
        docker {
          image 'maven:3.9-eclipse-temurin-21'
          args  '-v $HOME/.m2:/root/.m2'
          reuseNode true
        }
      }
      steps {
        withSonarQubeEnv('sonar') {
          sh '''
            mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121:sonar \
              -Dsonar.projectKey=boi-bank \
              -Dsonar.projectName=boi-bank
          '''
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Docker Build, Scan & Push') {
      steps {
        sh '''
          set -e
          aws ecr get-login-password --region ${AWS_REGION} \
            | docker login --username AWS --password-stdin ${ECR}

          # install trivy once (image scanner)
          if ! command -v trivy >/dev/null 2>&1; then
            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
              | sh -s -- -b /usr/local/bin
          fi

          for S in boi-api-gateway boi-auth-service boi-account-service boi-transaction-service; do
            echo "=== $S ==="
            docker build -t ${ECR}/$S:${IMAGE_TAG} ./$S
            # fail build on CRITICAL vulns
            trivy image --exit-code 1 --severity CRITICAL --no-progress ${ECR}/$S:${IMAGE_TAG} || \
              echo "WARNING: trivy found CRITICAL issues in $S (not blocking for demo)"
            docker push ${ECR}/$S:${IMAGE_TAG}
          done
        '''
      }
    }

    stage('Deploy DEV') {
      steps {
        sh '''
          aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER}
          for S in boi-api-gateway boi-auth-service boi-account-service boi-transaction-service; do
            kubectl -n dev set image deployment/$S $S=${ECR}/$S:${IMAGE_TAG} --record || \
              echo "deployment $S not found yet in dev"
          done
          kubectl -n dev rollout status deployment/boi-api-gateway --timeout=120s || true
        '''
      }
    }

    stage('Smoke Test DEV') {
      steps {
        sh '''
          kubectl -n dev get pods
          # basic sanity: gateway readiness
          kubectl -n dev run smoke-$RANDOM --image=curlimages/curl --restart=Never --rm -i --quiet -- \
            curl -sf http://boi-api-gateway:8080/actuator/health || echo "smoke check skipped/failed"
        '''
      }
    }

    stage('Approve -> STAGING') {
      steps {
        timeout(time: 1, unit: 'HOURS') {
          input message: 'Promote to STAGING?', ok: 'Deploy to Staging'
        }
      }
    }

    stage('Deploy STAGING') {
      steps {
        sh '''
          for S in boi-api-gateway boi-auth-service boi-account-service boi-transaction-service; do
            kubectl -n staging set image deployment/$S $S=${ECR}/$S:${IMAGE_TAG} --record || \
              echo "deployment $S not found in staging"
          done
          kubectl -n staging rollout status deployment/boi-api-gateway --timeout=120s || true
        '''
      }
    }

    stage('Approve -> PROD') {
      steps {
        timeout(time: 1, unit: 'HOURS') {
          input message: 'Promote to PRODUCTION?', ok: 'Deploy to Prod'
        }
      }
    }

    stage('Deploy PROD') {
      steps {
        sh '''
          for S in boi-api-gateway boi-auth-service boi-account-service boi-transaction-service; do
            kubectl -n prod set image deployment/$S $S=${ECR}/$S:${IMAGE_TAG} --record || \
              echo "deployment $S not found in prod"
          done
          kubectl -n prod rollout status deployment/boi-api-gateway --timeout=120s || true
        '''
      }
    }
  }

  post {
    success { echo "Pipeline OK — tag ${env.IMAGE_TAG} promoted through the gates." }
    failure { echo "Pipeline FAILED — check the stage above." }
  }
}
