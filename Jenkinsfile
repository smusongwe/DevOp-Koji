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
        ECS_CLUSTER = 'ECS-SERGE-CLUSTER'
        ECS_SERVICE = 'sergerservice'
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
         stage('docker build and tag') {
            steps {
                sh 'cp ./webapp/target/*.war .'
                sh 'sudo docker build -t ${IMAGENAME}:${IMAGE_TAG} .'
                sh 'sudo docker tag ${IMAGENAME}:${IMAGE_TAG} ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        } 
       stage('Deployment Approval') {
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
                sh 'docker rmi ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        } 
       stage('update ecs service') {
            steps {
                sh '/usr/local/bin/aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment --region ${AWS_REGION}'
            }
        }  
      stage('wait ecs service stable') {
            steps {
                sh '/usr/local/bin/aws ecs wait services-stable --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --region ${AWS_REGION}'
            }
        } 
    }
}
