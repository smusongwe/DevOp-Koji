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
                sh "mvn clean package sonar:sonar  -Dsonar.host.url=http://44.227.196.156:9000 -Dsonar.login=b1c9f5661d6a345428f463f5579aee81e94de3c7 -Dsonar.projectKey=jjtech -Dsonar.projectName=Haplet -Dsonar.Version=1.0"
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
          stage('AWS ecr login') {
            steps {
                sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECRREGISTRY}'
            }
        }        
         stage('docker build and tag') {
            steps {
                sh 'docker build -t ${IMAGENAME}:${IMAGE_TAG} .'
                sh 'docker tag ${IMAGENAME}:${IMAGE_TAG} ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        }  
       }   
    }
