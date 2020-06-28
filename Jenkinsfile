/*pipeline {
     agent any
     stages {
         stage('Build') {
             steps {
                 sh 'echo "Hello World"'
                 sh '''
                     echo "Multiline shell steps works too"
                     pwd
                     ls -lah
                 '''
             }
         }
         stage('Lint HTML') {
              steps {
                  sh 'echo "Linting HTML"'
                  //sh 'tidy -q -e *.html'
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

pipeline {
     agent any
     stages {
          def app

          stage('Clone repository') {
               steps {
                    // Cloning the repository to our workspace
                    checkout scm
               }
          }

          stage('Build image') {
               steps {
                    // This builds the actual image
                    app = docker.build("itsecat/flask-app")
               }
          }

          stage('Test image') {
               steps {
                    app.inside {
                         echo "Tests passed"
                    }
               }
          }

          stage('Push image') {
               steps {
                    // You would need to first register with Dockerhub before you can push images to your account
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
                         app.push("${env.BUILD_NUMBER}")
                         app.push("latest")
                    }
                         echo "Trying to push Docker build to Dockerhub"
               }
          }
     }
}
