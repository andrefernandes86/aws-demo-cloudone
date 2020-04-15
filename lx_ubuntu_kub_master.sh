#!/bin/bash
# Requirements
sudo su
sudo apt-get update
sudo apt-get install curl -y
sudo apt-get install wget -y
sudo apt-get install awscli -y

sleep 5

# Installing Docker
sudo apt-get install python -y
sleep 5
curl -fsSL https://get.docker.com | sh
sleep 5
sudo usermod -aG docker root
sleep 5

# Install Kubectl
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

#Install KOPS
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x ./kops
sudo mv ./kops /usr/local/bin/

# AWS Configuration
# Create Bucket
aws s3api create-bucket --bucket af-cloudone-demo --region us-east-1
# Enable Versioning
aws s3api put-bucket-versioning --bucket af-cloudone-demo --versioning-configuration Status=Enabled
# Enable Bucket Encryption
aws s3api put-bucket-encryption --bucket af-cloudone-demo --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Set Environment Variables for KOPS
export NAME=af-cloudone-demo.k8s.local
export KOPS_STATE_STORE=s3://af-cloudone-demo

# Create KOPS Cluster Configuration
kops create cluster --zones us-east-1a,us-east-1b,us-east-1c ${NAME}

# Generate a ssh key for KOPS
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa
kops create secret --name ${NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub

# Apply KOPS Configuration and Deploy your Cluster
kops update cluster ${NAME} --yes

# Suggestions:
# * validate cluster: kops validate cluster
# * list nodes: kubectl get nodes --show-labels
# * ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.af-cloudone-demo.k8s.local
# * the admin user is specific to Debian. If not using Debian please use the appropriate user based on your OS.
# kops validate cluster
# kops delete cluster --name ${NAME} --yes

# Installing Smart Check
aws ecr create-repository --repository-name ecr-af-cloudone-demo
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
kubectl config current-context

kubectl create serviceaccount \
--namespace kube-system \
tiller
kubectl create clusterrolebinding tiller-cluster-role \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:tiller
helm init --service-account tiller

kubectl create serviceaccount \
--namespace kube-system \
tiller
kubectl create clusterrolebinding tiller-cluster-role \
--clusterrole=cluster-admin \
--serviceaccount=kube-system:tiller
helm init --service-account tiller

export SERVICE_IP=$(kubectl get svc proxy -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo https://$SERVICE_IP:443

echo Username: $(kubectl get secrets -o jsonpath='{ .data.userName }' deepsecurity-smartcheck-auth | base64 -
-decode)
echo Password: $(kubectl get secrets -o jsonpath='{ .data.password }' deepsecurity-smartcheck-auth | base64 --
decode)

