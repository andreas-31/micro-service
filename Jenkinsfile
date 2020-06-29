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
                             python3 -m venv ~/.devops
                             source ~/.devops/bin/activate
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
                             source ~/.devops/bin/activate
                             pylint3 --disable=R,C,W1203 "$file_to_check"
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
          
          stage('Configure kubectl') {
               steps {
                    sh 'echo "Configuring kubectl for accessing the EKS cluster"'
                    sh '''
                         aws eks --region us-west-2 update-kubeconfig --name eks-example --kubeconfig "$HOME/.kube/eks-example"
                         export KUBECONFIG="$HOME/.kube/eks-example"
                         kubectl get svc
                    '''
               }
          }
         
          stage('Deploy app to EKS') {
               steps {
                    sh 'echo "Deploying app to EKS"'
                    sh '''
                         aws eks --region us-west-2 update-kubeconfig --name eks-example --kubeconfig "$HOME/.kube/eks-example"
                         export KUBECONFIG="$HOME/.kube/eks-example"
                         kubectl apply -f kubernetes/flask-app.yml
                         echo "See next output for external IP of elastic load balancer:"
                         kubectl get svc -o wide
                    '''
               }
          }
     }
}
