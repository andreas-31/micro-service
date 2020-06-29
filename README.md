# micro-service
CI/CD pipeline for micro services applications with blue/green deployment

## Description of chosen approach:
1. Github Repository: holds all the source code of the web application, the Dockerfile, the Jenkinsfile, the ansible playbook, and the CloudFormation stack files
1. Jenkins Multibranch Pipeline: Jenkins is set up to process the branches "master", "blue", and "green" in the GitHub repository
1. Web Application: is based on the Python framework "Flask". The website is served by Python on port TCP/5000.
1. Linting of Code: hadolint is used to lint the Dockerfile. pylint is used to lint the Python code.
1. Kubernetes Cluster: ansible is used to spin up an Amazon EKS cluster by executing CloudFormation stacks for creation of VPC, EKS Cluster, and EKS Nodegroup.
1. Docker Image: the web app is dockerized and pushed to Docker Hub [itsecat/flask-app](https://hub.docker.com/repository/docker/itsecat/flask-app)
1. Application Deployment: kubectl command is used to create
   1. Blue load balancer (ELB), blue deployment, blue service
   1. Green load balancer (ELB), green deployment, green service
