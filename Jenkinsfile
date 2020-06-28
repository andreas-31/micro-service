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
                       sh '''
                            appname=flask-app
                            dockerpath="${USERNAME}/$appname"
                            
                            # Step 3:  
                            # Authenticate & tag
                            echo "Docker ID and Image: $dockerpath"
                            docker login --username "${USERNAME}" --password "${PASSWORD}"
                            docker tag "$appname" "$dockerpath"

                            # Step 4:
                            # Push image to a docker repository
                            docker push "$dockerpath"
                            
                            # To push a new tag to this repository
                            # docker push itsecat/flask-app:tagname
                        '''
                   }
               }
         }
          
         stage('Deploy EKS infrastructure with ansible and CloudFormation') {
              steps {
                   sh '''
                         ansible-playbook -i inventory main.yaml
                   '''
              }
         }
     }
}
