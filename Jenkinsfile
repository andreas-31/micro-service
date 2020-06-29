pipeline {
     agent any
     stages {
          stage('Lint Dockerfile') {
               steps {
                    sh 'echo "This is a linter for Dockerfiles"'
                    sh '''
                         file_to_check="Dockerfile"
                         if [ -f "$file_to_check" ]; then
                             echo "$file_to_check exists."
                             hadolint "$file_to_check"
                         fi
                    '''
               }
          }
          
          stage('Lint Python code') {
               steps {
                    sh 'echo "This is a linter for Python 3 source code"'
                    sh '''
                         file_to_check="the_app/app.py"
                         if [ -f "$file_to_check" ]; then
                             echo "$file_to_check exists."
                             python3 -m venv ~/.devops
                             . ~/.devops/bin/activate
                             pip3 install --upgrade pip
                             pip3 install -r requirements.txt
                             pylint --disable=R,C,W1203 "$file_to_check"
                         fi
                    '''
               }
          }
          
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
          
          stage('Create EKS cluster') {
               steps {
                    sh '''
                          start=`date +"%Y-%m-%d %T"`
                          echo "Starting ansible-playbook at $start"
                    '''
                    sh '''
                          ansible-playbook -i inventory main.yml
                    '''
                    sh '''
                          end=`date +"%Y-%m-%d %T"`
                          echo "Finished ansible-playbook at $end"
                    '''
               }
         }
          
         stage('Deploy blue app to EKS') {
              when {
                   branch 'blue'
              }
              steps {
                   sh 'echo "Deploying blue app to EKS"'
                   sh '''
                        pwd
                        cp kubernetes/flask-app.yml kubernetes/flask-app-blue.yml
                        sed -i 's/flaskapp/flaskapp-blue/g' kubernetes/flask-app-blue.yml
                        aws eks --region us-west-2 update-kubeconfig --name eks-example --kubeconfig "$HOME/.kube/eks-example"
                        export KUBECONFIG="$HOME/.kube/eks-example"
                        kubectl apply -f kubernetes/flask-app-blue.yml
                        rm kubernetes/flask-app-blue.yml
                   '''
              }
         }
          
         stage('Deploy green app to EKS') {
              when {
                   branch 'green'
              }
              steps {
                   sh 'echo "Deploying green app to EKS"'
                   sh '''
                        pwd
                        cp kubernetes/flask-app.yml kubernetes/flask-app-green.yml
                        sed -i 's/flaskapp/flaskapp-green/g' kubernetes/flask-app-green.yml
                        aws eks --region us-west-2 update-kubeconfig --name eks-example --kubeconfig "$HOME/.kube/eks-example"
                        export KUBECONFIG="$HOME/.kube/eks-example"
                        kubectl apply -f kubernetes/flask-app-green.yml
                        rm kubernetes/flask-app-green.yml
                   '''
              }
         }
     }
}
