pipeline {
    agent any
    tools {
        maven 'maven3.8'
        jdk 'jdk8'
    }
    environment { 
        AWS_REGION = 'us-west-2'
        ECRREGISTRY = '007600611043.dkr.ecr.us-west-2.amazonaws.com'
        IMAGENAME = 'demomk'
        IMAGE_TAG = 'latest'
    }
    stages {
       stage ('Clone') {
          steps {
                checkout scm
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }
        stage('Unit Tests') {
            steps {
                sh 'mvn surefire:test'
            }
        }
        // Now Maven is intergrating Sonar-scanner for indept and rubost test, code smell, code volnurability
        stage("build & SonarQube analysis") {
            agent any
            steps {
                withSonarQubeEnv('sonarserver') {
                  sh "mvn clean package sonar:sonar  -Dsonar.host.url=http://34.221.157.212:8443 -Dsonar.login=9d459e9a90f58879082ce0d24f02e929450af88b -Dsonar.projectKey=jjtech -Dsonar.projectName=Haplet -Dsonar.Version=1.0"
              }
            }
          }
         stage('Deployment Approval') {
            steps {
              script {
                timeout(time: 10, unit: 'MINUTES') {
                 input(id: 'Deploy Gate', message: 'Deploy Application to Dev ?', ok: 'Deploy')
                 }
               }
            }
          }
          stage('docker build and tag') {
            steps {
                sh 'cp ./webapp/target/*.war .'
                sh 'sudo docker build -t ${IMAGENAME}:${IMAGE_TAG} .'
                sh 'sudo docker tag ${IMAGENAME}:${IMAGE_TAG} ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        } 
          stage('docker push') {
            steps {
                sh 'sudo aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 007600611043.dkr.ecr.us-west-2.amazonaws.com'
                sh 'sudo docker push ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        }
          stage('update ecs service') {
            steps {
                sh 'aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment --region ${AWS_REGION}'
            }
        }            
    }   
 }
