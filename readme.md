# Azure Kubernetes Service (aks) Demo

Content based on information from [Martin Jensen](https://kubecloud.io/kubernetes-dashboard-on-arm-with-rbac-61309310a640?gi=602d9419dcf) and [Pascal Naber](https://pascalnaber.wordpress.com/2018/06/17/access-dashboard-on-aks-with-rbac-enabled/)

## Deploy an AKS (managed Kubernetes) Cluster

Define the deployment variables used by the subsequent Azure CLI commands

```bash
resource_group=k8s-jp-east
location=japaneast
k8s_name=k8s-cl01
user_name=bot6
```

Create the resource group for the deployment

```bash
az group create --name $resource_group --location $location
```

Validate available Kubernetes versions for the region

```bash
az aks get-versions --location $location
```

Deploy the cluster

```bash
az aks create --resource-group $resource_group --name $k8s_name \
    --node-count 2 \
    --generate-ssh-keys \
    --kubernetes-version 1.10.5 \
    --max-pods 1000 \
    --enable-addons http_application_routing
```

## Connect to the Cluster

Install Kubernetes CLI (not required when using the Azure Cloud Shell)

```bash
sudo az aks install-cli
```

Get access credentials for a managed Kubernetes cluster, store in .kube/config

```bash
az aks get-credentials --resource-group $resource_group --name $k8s_name
```

## Enable the Kubernetes dashboard (Optional)

>**CAUTION**: This configuration grants the cluster-admin role to the dashboard service account. This is for evaluation purposes only. Addition information on cluster [roles](https://kubernetes.io/docs/admin/authorization/rbac/#user-facing-roles)

```bash
kubectl create serviceaccount dashboard -n default

kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
```

Get the dashboard service account token

```bash
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
```

Start the proxy

```bash
kubectl proxy
```

Login with the following URL

http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/login

http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/

## Deploy an Application

Create a file named azure-vote.yaml with the following code

```bash
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
```

Deploy the application to the cluster

```bash
kubectl apply -f azure-vote.yaml
```

Monitor the deployment, get the EXTERNAL-IP value from the output

```bash
kubectl get service azure-vote-front --watch
```

Browse to the enternal IP and verify the application is working

## Manage the Cluster

Increase the node count from 2 to 3

```bash
az aks scale --resource-group $resource_group --name $k8s_name --node-count 3
```

Verify pods, and manually change the number of pods in the azure-vote-front deployment from 1 to 5

```bash
kubectl get pods

kubectl scale --replicas=5 deployment/azure-vote-front

kubectl get pods
```

Kubernetes supports horizontal pod autoscaling to adjust the number of pods in a deployment depending on CPU utilization or other select metrics. The Metrics Server is used to provide resource utilization to Kubernetes. To install the Metrics Server, clone the metrics-server GitHub repo and install the example resource definitions. To view the contents of these YAML definitions, see Metrics Server for Kuberenetes 1.8+.

```bash
git clone https://github.com/kubernetes-incubator/metrics-server.git

kubectl create -f metrics-server/deploy/1.8+/
```

Autoscale the number of pods in the azure-vote-front deployment. Here, if CPU utilization exceeds 50%, the autoscaler increases the pods to a maximum of 10.

```bash
kubectl autoscale deployment azure-vote-front --cpu-percent=50 --min=3 --max=10

kubectl get hpa
```