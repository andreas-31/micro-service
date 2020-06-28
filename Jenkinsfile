pipeline {
     agent any
     stages {
         stage('Build docker image') {
             steps {
                 sh 'echo "Building docker image"'
                 sh '''
                    # Step 1:
                    # Create dockerpath
                    username=itsecat
                    appname=flask-app
                    dockerpath="$username/$appname"

                    # Step 2: Build the docker image
                    docker build --tag "$appname" .
                 '''
             }
         }
         
         stage('Push image to Docker Hub') {
              steps {
                   withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                       sh 'echo ${USERNAME}'
                       sh 'echo ${PASSWORD}'
                   }
               }
         }
     }
}
