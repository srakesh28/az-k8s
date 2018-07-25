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
echo 'Create the resource group for the deployment'
echo
echo 'az group create --name $resource_group --location $location'
read -n1 -r -p 'Press any key...' key

az group create --name $resource_group --location $location

echo
echo
echo 'Validate available Kubernetes versions for the region'
echo
echo 'az aks get-versions --location $location'
read -n1 -r -p 'Press any key...' key

az aks get-versions --location $location

echo
echo
echo 'Deploy the cluster'
echo
echo 'az aks create --resource-group $resource_group --name $k8s_name \'
echo     '--node-count 2 \'
echo     '--generate-ssh-keys \'
echo     '--kubernetes-version 1.10.5 \'
echo     '--max-pods 1000 \'
echo     '--enable-addons http_application_routing'
read -n1 -r -p 'Press any key...' key

az aks create --resource-group $resource_group --name $k8s_name \
    --node-count 2 \
    --generate-ssh-keys \
    --kubernetes-version 1.10.5 \
    --max-pods 1000 \
    --enable-addons http_application_routing

echo
echo
echo 'Connect to the cluster'
echo
echo 'Install Kubernetes CLI. This is not required when using the Azure Cloud Shell'
echo
echo 'sudo az aks install-cli'
read -n1 -r -p 'Press any key...' key

sudo az aks install-cli

echo
echo
echo 'Get access credentials for a managed Kubernetes cluster'
echo
echo 'az aks get-credentials --resource-group $resource_group --name $k8s_name'
read -n1 -r -p 'Press any key...' key

az aks get-credentials --resource-group $resource_group --name $k8s_name

echo
echo
echo 'Enable the Kubernetes dashboard (Optional)'
echo
echo 'kubectl create serviceaccount dashboard -n default'
echo 'kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard'
read -n1 -r -p 'Press any key...' key

kubectl create serviceaccount dashboard -n default
kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard

echo
echo
echo 'Get the dashboard service account token'
echo
echo 'kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode'
read -n1 -r -p 'Press any key...' key

kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

echo
echo
echo 'Start the proxy'
echo
echo 'kubectl proxy'
echo
echo 'Login with the following URL'
echo
echo 'http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/login'
echo
echo 'Access the Dashboard'
echo
echo 'http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/'
read -n1 -r -p 'Press any key...' key

kubectl proxy