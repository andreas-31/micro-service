/*pipeline {
     agent any
     stages {
         stage('Build') {
             steps {
                 sh 'echo "Hello World"'
                 sh '''
                     echo "Multiline shell steps works too"
                     pwd
                     [ -e "micro-service" ] && rm -fr "micro-service"
                     git clone https://github.com/andreas-31/micro-service.git
                     ls -lah
                 '''
             }
         }
         stage('Lint HTML') {
              steps {
                  sh 'tidy -q -e *.html'
              }
         }
         stage('Security Scan') {
              steps { 
                 aquaMicroscanner imageName: 'alpine:latest', notCompliesCmd: 'exit 4', onDisallowed: 'fail', outputFormat: 'html'
              }
         }         
         stage('Upload to AWS') {
              steps {
                  withAWS(region:'us-west-2',credentials:'aws-static') {
                  sh 'echo "Uploading content with AWS creds"'
                      s3Upload(pathStyleAccessEnabled: true, payloadSigningEnabled: true, file:'index.html', bucket:'static-jenkins-pipeline-ag')
                  }
              }
         }
     }
}*/

node {
     def app
     
     stage('Clone repository') {
          // Cloning the repository to our workspace
          checkout scm
     }
     
     stage('Build image') {
          // This builds the actual image
          app = docker.build("itsecat/flask-app")
     }
     
     stage('Test image') {
          app.inside {
               echo "Tests passed"
          }
     }
     
     stage('Push image') {
          // You would need to first register with Dockerhub before you can push images to your account
          docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
               app.push("${env.BUILD_NUMBER}")
               app.push("latest")
          }
               echo "Trying to push Docker build to Dockerhub"
     }
     
     stage('Deploy blue branch') {
          when {
               branch 'blue'
          }
          sh 'echo "Deploying BLUE branch"'
          sh 'echo "Hello World"'
          sh '''
              echo "Multiline shell steps works too"
              pwd
              ls -lah
          '''
     }
     
     stage('Deploy green branch') {
          when {
               branch 'green'
          }
          sh 'echo "Deploying GREEN branch"'
          sh 'echo "Hello World"'
          sh '''
              echo "Multiline shell steps works too"
              pwd
              ls -lah
          '''
     }
     
     stage('Deploy blue branch') {
          when {
               branch 'master'
          }
          sh 'echo "Deploying MASTER branch"'
          sh 'echo "Hello World"'
          sh '''
              echo "Multiline shell steps works too"
              pwd
              ls -lah
          '''
     }
}
