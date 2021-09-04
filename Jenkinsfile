pipeline {
    agent any
    tools {
        maven 'maven3.8'
        jdk 'jdk'
    }
    environment { 
        AWS_REGION = 'us-west-2'
        ECRREGISTRY = '735972722491.dkr.ecr.us-west-2.amazonaws.com'
        IMAGENAME = 'haplet-registory'
        IMAGE_TAG = 'latest'
    }
    stages {
       stage ('Cloning git & Build') {
          steps {
                checkout scm
            }
        }
         stage('Compile') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }
         stage('Unit Tests Execution') {
            steps {
                sh 'mvn surefire:test'
            }
        }
         stage("Static Code analysis With SonarQube") {
            agent any
            steps {
              withSonarQubeEnv('sonnar-scanner') {
                sh "mvn clean package sonar:sonar -Dsonar.host.url=http://52.39.249.160:9000 -Dsonar.login=cc92b9fece4552a752667e25ff8a1064f7447e3d -Dsonar.projectKey=jenkins -Dsonar.projectName=haplet -Dsonar.projectVersion=1.0"
              }
            }
          }
        stage('docker build and Tag Application') {
            steps {
                 sh 'cp ./webapp/target/webapp.war .'
                 sh 'docker build -t ${IMAGENAME} .'
                 sh 'docker tag ${IMAGENAME}:${IMAGE_TAG} ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        }
        stage('Approve to Deploy to EC2') {
            steps {
              script {
                timeout(time: 20, unit: 'MINUTES') {
                 input(id: 'Deploy Gate', message: 'Deploy Application to Dev ?', ok: 'Deploy')
                 }
               }
            }
   
        } 
         // For non-release candidates, This can be as simple as tagging the artifact(s) with a timestamp and the build number of the job performing the CI/CD process.
         stage('Publish the Artifact to ECR') {
            steps {
                sh 'docker push ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        }       
        }
}
