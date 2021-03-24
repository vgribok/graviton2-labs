---
title: "AmazonEKS : Deploy a multi-architecture application"
date: 2020-04-10T11:14:51-06:00
weight: 40
---

Now you're ready to deploy a multi-architecture Kubernetes Application.

1. Start by reviewing contents of the Kubernetes deployment manifest in file graviton2-labs/graviton2/cs_graviton/Deployment.yaml

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multiarch-deployment
  namespace: multiarch
  labels:
    app: multiarch-app
spec:
  replicas: 4
  selector:
    matchLabels:
      app: multiarch-app
  template:
    metadata:
      labels:
        app: multiarch-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: beta.kubernetes.io/arch
                operator: In
                values:
                - amd64
                - arm64
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - multiarch-app
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: multiarch-container
        image: {{container_uri}} 
        ports:
        - containerPort: 80
```

This manifest will deploy four pods across all EKS nodes (both amd64 and arm64).

2. Use the following command to initiate the deployment :

```bash
cd ~/environment/graviton2-labs
CONTAINER_URI=`aws ssm get-parameter --name "graviton_lab_container_uri" | jq -r .Parameter.Value`
cat graviton2/cs_graviton/Deployment.yaml | sed "s#{{container_uri}}#$CONTAINER_URI#" | kubectl apply -f -
```

3. You can ckeck the status of your deployment by executing:

```bash
kubectl get svc,deployment -n multiarch
```

4. Access multi-architecture application via LoadBalancer endpoint 

{{% notice tip %}} 
It will take several minutes for the ELB to become healthy and start passing traffic to the pods.
{{% /notice %}}

```bash
ELB=$(kubectl get service multiarch-service -n multiarch -o json | jq -r '.status.loadBalancer.ingress[].hostname')
for i in {1..8}; do curl -m3 $ELB ; echo; done
```
{{% notice tip %}} 
You can also copy/paste the loadBalancer hostname into your browser and see the application running. 
{{% /notice %}}

{{% notice note %}}
Please note we are using a single image tag with Amazon ECR, and Amazon EKS. Native multi-architecture support to automatically allows to select
the right container for each of nodegroups.
{{% /notice %}}

### Congratulations! Now you have deployed multi-architecture application across two nodegroups using x86 and ARM64 instance types.


Optional: You can verify a Failure scenario by forcing the use of a single architecture docker image.
Start by scaling down the deployment, changing the image tag to point to architecture-specific build, and scaling the 
deployment back up to the original number of replicas.

```bash
kubectl -n multiarch scale deployment multiarch-deployment --replicas=0
kubectl -n multiarch set image deployment/multiarch-deployment multiarch-container=$CONTAINER_URI-x86
kubectl -n multiarch scale deployment multiarch-deployment  --replicas=4
```

After deployment stabilizes, execute the follwoing command to check deployment status:

```bash 
kubectl get pod -n multiarch 
```

You should be able to see output similar to the one below where only two pods report "Running", while two show "CrashLoopBackOff" or "Error" status.

```bash
NAME                                    READY   STATUS             RESTARTS   AGE
multiarch-deployment-857dbcdd7c-5455t   0/1     CrashLoopBackOff   6          9m33s
multiarch-deployment-857dbcdd7c-l48zd   1/1     Running            0          9m33s
multiarch-deployment-857dbcdd7c-ptf65   1/1     Running            0          9m33s
multiarch-deployment-857dbcdd7c-xk8vh   0/1     CrashLoopBackOff   6          9m33s
```










