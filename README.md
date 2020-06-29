# micro-service
CI/CD pipeline for micro services applications with blue/green deployment

## Description of Chosen Approach
1. Github Repository: holds all the source code of the web application, the Dockerfile, the Jenkinsfile, the ansible playbook, and the CloudFormation stack files
1. Jenkins Multibranch Pipeline: Jenkins is set up to process the branches "master", "blue", and "green" in the GitHub repository
1. Web Application: is based on the Python framework "Flask". The website is served by Python on port TCP/5000.
1. Linting of Code: hadolint is used to lint the Dockerfile. pylint is used to lint the Python code.
1. Kubernetes Cluster: ansible is used to spin up an Amazon EKS cluster by executing CloudFormation stacks for creation of VPC, EKS Cluster, and EKS Nodegroup.
1. Docker Image: the web app is dockerized and pushed to Docker Hub [itsecat/flask-app](https://hub.docker.com/repository/docker/itsecat/flask-app)
1. Application Deployment: kubectl command is used to create
   1. Blue load balancer (ELB), blue deployment, blue service
   1. Green load balancer (ELB), green deployment, green service
   
## Files and Directories Listing
1. cloudformation: YAML files describing the stacks for spinning up the EKS cluster
   1. eks-cluster.yml: creates resource AWS::EKS::Cluster (EKS control plane)
   1. eks-nodegroup.yml: creates resource AWS::EKS::Nodegroup (EKS worker nodes)
   1. vpc.yml: creates all AWS networking resources required for the EKS cluster
1. kubernetes: contains the file "flask-app.yml" that describes the Kubernetes deployment and Kubernetes service
1. the_app: contains all the Python, HTML, and CSS files that are part of the Flask web application
1. vars: contains main.yml for defining and setting variables for the ansible playbook
1. ansible.cfg: ansible configuration file
1. delete.yml: used for deleting all AWS resources that have been created for EKS Cluster, EKS Nodegroup, and networking. Execute `ansible-playbook -i inventory delete.yml`
