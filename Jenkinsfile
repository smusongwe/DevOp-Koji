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
        ECS_CLUSTER = 'sergeocluster'
        ECS_SERVICE = 'sergeoservice'
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
                  sh "mvn clean package sonar:sonar  -Dsonar.host.url=http://34.217.92.179:8443 -Dsonar.login=9d459e9a90f58879082ce0d24f02e929450af88b -Dsonar.projectKey=jjtech -Dsonar.projectName=Haplet -Dsonar.Version=1.0"
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
        //stage('Login To ECR') {
          //  steps {
              //  sh 'sudo /usr/local/bin/aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECRREGISTRY}' 
           // }
      //  } 
     // For non-release candidates, This can be as simple as tagging the artifact(s) with a timestamp and the build number of the job performing the CI/CD process.
        stage('Publish the Artifact to ECR') {
            steps {
                sh 'sudo docker push ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
                sh 'sudo docker rmi ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        } 
       stage('update ecs service') {
            steps {
                sh 'sudo /usr/local/bin/aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment --region ${AWS_REGION}'
            }
        }  
      stage('wait ecs service stable') {
            steps {
                sh 'sudo /usr/local/bin/aws ecs wait services-stable --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --region ${AWS_REGION}'
            }
        } 
    }
}
