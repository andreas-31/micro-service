pipeline {
     agent any
     stages {
         stage('Build') {
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
     }
}
