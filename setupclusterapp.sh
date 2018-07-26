#!/bin/bash

echo
echo
echo 'Define the deployment variables used by the subsequent Azure CLI commands'
echo
echo 'resource_group=k8s-jp-east'
echo 'location=japaneast'
echo 'k8s_name=k8s-cl01'
echo 'user_name=bot6'
read -n1 -r -p 'Press any key...' key

resource_group=k8s-jp-east
location=japaneast
k8s_name=k8s-cl01
user_name=bot6

echo
echo
echo 'Deploy an application the previously created AKS cluster'
echo
echo 'Create a file named azure-vote.yaml'
echo
read -n1 -r -p 'Press any key...' key

cat <<EOF >azure-vote.yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      containers:
      - name: azure-vote-back
        image: redis
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      containers:
      - name: azure-vote-front
        image: microsoft/azure-vote-front:v1
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
EOF

echo
echo
echo 'Deploy the application to the cluster'
echo
echo 'kubectl apply -f azure-vote.yaml'
read -n1 -r -p 'Press any key...' key

kubectl apply -f azure-vote.yaml

echo
echo
echo 'Monitor the deployment, copy the EXTERNAL-IP value from the output'
echo
echo 'kubectl get service azure-vote-front --watch'
read -n1 -r -p 'Press any key...' key

kubectl get service azure-vote-front --watch

echo
echo
echo 'Browse to the enternal IP and verify the application is working'
read -n1 -r -p 'Press any key...' key

echo
echo
echo 'Manage the Cluster'
echo
echo 'Increase the cluster node count from 2 to 3'
echo
echo 'az aks scale --resource-group $resource_group --name $k8s_name --node-count 3'
read -n1 -r -p 'Press any key...' key

az aks scale --resource-group $resource_group --name $k8s_name --node-count 3

echo
echo
echo 'Show the pods in the cluster'
echo
echo 'kubectl get pods'
read -n1 -r -p 'Press any key...' key

kubectl get pods

echo
echo
echo 'Manually change the number of pods in the azure-vote-front deployment from 1 to 5'
echo
echo 'kubectl scale --replicas=5 deployment/azure-vote-front'
read -n1 -r -p 'Press any key...' key

kubectl scale --replicas=5 deployment/azure-vote-front

echo
echo
echo 'Show the number of pods has increase'
echo
echo 'kubectl get pods'
read -n1 -r -p 'Press any key...' key

kubectl get pods

echo
echo
echo 'Kubernetes supports horizontal pod autoscaling to adjust the number of pods in a deployment depending on CPU utilization or other select metrics.'
echo
echo 'git clone https://github.com/kubernetes-incubator/metrics-server.git'
echo
echo 'kubectl create -f metrics-server/deploy/1.8+/'
read -n1 -r -p 'Press any key...' key

git clone https://github.com/kubernetes-incubator/metrics-server.git

kubectl create -f metrics-server/deploy/1.8+/

echo
echo
echo 'Autoscale the number of pods in the azure-vote-front deployment. If CPU utilization exceeds 50%, the autoscaler increases the pods to a maximum of 10.'
echo
echo 'kubectl autoscale deployment azure-vote-front --cpu-percent=50 --min=3 --max=10'
read -n1 -r -p 'Press any key...' key

kubectl autoscale deployment azure-vote-front --cpu-percent=50 --min=3 --max=10

echo
echo
echo 'Show the cluster autoscale configuration'
echo
echo 'kubectl get hpa'
read -n1 -r -p 'Press any key...' key

kubectl get hpa