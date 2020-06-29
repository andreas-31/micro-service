# micro-service
CI/CD pipeline for micro services applications with blue/green deployment

## Description of Chosen Approach
1. Github Repository: holds all the source code of the web application, the Dockerfile, the Jenkinsfile, the ansible playbook, and the CloudFormation stack files
1. Jenkins Multibranch Pipeline: Jenkins is set up to process the branches "master", "blue", and "green" in the GitHub repository
1. Web Application: is based on the Python framework "Flask". The website is served by Python on port TCP/5000.
1. Linting of Code: hadolint is used to lint the Dockerfile. pylint is used to lint the Python code.
1. Kubernetes Cluster: ansible is used to spin up an Amazon EKS cluster by executing CloudFormation stacks for creation of VPC, EKS Cluster, and EKS Nodegroup.
1. Docker Image: the web app is dockerized and pushed to Docker Hub [itsecat/flask-app](https://hub.docker.com/repository/docker/itsecat/flask-app)
1. Application Deployment: kubectl command is used as part of the Jenkins pipeline to create
   1. Blue load balancer (ELB), blue deployment, blue service
   1. Green load balancer (ELB), green deployment, green service
   
## Files and Directories Listing
1. cloudformation: YAML files describing the stacks for spinning up the EKS cluster. These files are read by ansible and are sent towards CloudFormation.
   1. eks-cluster.yml: creates resource AWS::EKS::Cluster (EKS control plane)
   1. eks-nodegroup.yml: creates resource AWS::EKS::Nodegroup (EKS worker nodes)
   1. vpc.yml: creates all AWS networking resources required for the EKS cluster
1. kubernetes: contains the file "flask-app.yml" that describes the Kubernetes deployment and Kubernetes service
1. the_app: contains all the Python, HTML, and CSS files that are part of the Flask web application
1. vars: contains main.yml for defining and setting variables for the ansible playbook main.yml
1. Dockerfile: describes how to containerize the demo web application
1. Jenkinsfile: describes the declarative Jenkins pipeline for building the Kubernetes/EKS infrastructure as well as linting, pushing, and deploying the application
1. ansible.cfg: ansible configuration file
1. delete.yml: used for deleting all AWS resources that have been created for EKS Cluster, EKS Nodegroup, and networking. Execute `ansible-playbook -i inventory delete.yml`
1. inventory: ansible file holding information about hosts and connections
1. main.yml: YAML file describing the ansible playbook that is used for creating all AWS resources that are necessary for EKS Cluster, EKS Nodegroup, and networking. Execute `ansible-playbook -i inventory main.yml`
1. requirements.txt: defines Python modules that are required for linting and running the Flask web application

## Jenkins Pipeline Steps and Requirements
### Setup
An EC2 Ubuntu 18.04.4 LTS instance was used to install Jenkins and the CloudBees Credentials plugin. An IAM policy "JenkinsMinimumSecurityModel" was assigned to an IAM role for the Jenkins EC2 instance in order to allow access to other AWS services like CloudFormation, EKS, or EC2/ELB.
### Step: Lint Dockerfile
[hadolint](https://github.com/hadolint/hadolint) was installed manually on the system.
```
wget https://github.com/hadolint/hadolint/releases/download/v1.18.0/hadolint-Linux-x86_64
mv hadolint-Linux-x86_64 hadolint
chmod +x hadolint
sudo install hadolint /usr/local/bin/
```
### Step: Lint Python Code
pylint will be automatically installed into a Python 3.6 venv (virtual enviroment) during execution of pipeline. pylint is listed in the requirements.txt file.
### Step: Build Docker Image
Docker was installed manually on the system. The user "jenkins" was added to group "docker" to allow building of docker images.
```
$ sudo apt-get update
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce docker-ce-cli containerd.io
$ sudo usermod -aG docker $USER && newgrp docker
$ docker run hello-world
```
### Push Image to Docker Hub
The credentials for the Docker Hub account have been added to Jenkins credential store. Username and password are fetched from the store and are inserted into the docker login command via Jenkins environment variables provided by the withCredentials clause.
### Create EKS cluster
[boto3](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html#installation) and [aws CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html#cliv2-linux-install) have been installed manually on the system.
`sudo apt install python-boto3`
boto3 is using the AWS credentials that have to be set up manually by running `aws configure` as user 'jenkins' `sudo su - jenkins`. ansible-playbook uses boto3 to send CloudFormation YAML files to AWS CloudFormation for executing stacks for EKS Cluster, EKS Nodegroup, and VPC network infrastructure. The creations of resources can take up to 20 minutes.
### Deploy blue or green app to EKS
Tool [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) was installed manually on the system.
```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2 
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update 
sudo apt-get install -y kubectl 
```
kubectl is used in this step of the Jenkins pipeline for deleting (if any) and creating blue or green (depending on git branch) deployments and services on Kubernetes (EKS). aws eks command is used as part of the pipeline to configure kubectl to access the EKS control plane endpoint:
```
aws eks --region us-west-2 update-kubeconfig --name eks-example --kubeconfig "$HOME/.kube/eks-example"
export KUBECONFIG="$HOME/.kube/eks-example"
kubectl delete service flaskapp-blue
kubectl delete deployments flaskapp-blue
kubectl apply -f kubernetes/flask-app-blue.yml
```
Note: if not running Jenkins in an EC2 instance without proper permissions, the tool [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) would also have to be installed alongside kubectl.
## Accessing the Web App
The publicly accessible URLs that are exposed by the load balancers for blue and green deployment can be queried with kubectl:
```
$ kubectl get svc
NAME             TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)          AGE
flaskapp-blue    LoadBalancer   10.100.182.119   ae8ca2a93345b4777b2010e91e99330e-1439484598.us-west-2.elb.amazonaws.com   5000:31632/TCP   3h33m
flaskapp-green   LoadBalancer   10.100.24.235    a825ab26062f74aad82f3f6baf277715-764107461.us-west-2.elb.amazonaws.com    5000:30432/TCP   3h46m
kubernetes       ClusterIP      10.100.0.1       <none>                                                                    443/TCP          12h
```
In my case the URLs are:
1. [Blue Deployment](http://a825ab26062f74aad82f3f6baf277715-764107461.us-west-2.elb.amazonaws.com:5000/)
1. [Green Deployment](http://a825ab26062f74aad82f3f6baf277715-764107461.us-west-2.elb.amazonaws.com:5000/)

In order to have one URL for the end-user to access, a Route53 domain could be registered and an A record added for pointing to the ELB.
