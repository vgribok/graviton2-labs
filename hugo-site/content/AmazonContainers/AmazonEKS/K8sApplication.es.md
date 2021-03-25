---
title: "AmazonEKS : Implementación de una aplicación multi-arquitectura"
date: 2020-04-10T11:14:51-06:00
weight: 40
---

Ahora estamos listos para implementar una aplicación multi-arquitectura sobre kubernetes

1. Revisa el contenido del manifiesto de implementación de kubernetes en el archivo: graviton2-labs/graviton2/cs_graviton/Deployment.yaml

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

Este manifiesto implementará cuatro pods en todos los nodos de EKS (tanto en los x86 como los ARM64).

2. Utiliza el siguiente comando para iniciar la implementación:

```bash
cd ~/environment/graviton2-labs
CONTAINER_URI=`aws ssm get-parameter --name "graviton_lab_container_uri" | jq -r .Parameter.Value`
cat graviton2/cs_graviton/Deployment.yaml | sed "s#{{container_uri}}#$CONTAINER_URI#" | kubectl apply -f -
```

3. Puedes revisar el estatus de la implementación ejecutando el siguiente comando:

```bash
kubectl get svc,deployment -n multiarch
```

4. Accede a la aplicación multi-arquitectura via el DNS del balanceador de carga:

{{% notice tip %}} 
Tomará varios minutos para que el balanceador pase a estatus saludable y comience a enviar tráfico a los pods
{{% /notice %}}

```bash
ELB=$(kubectl get service multiarch-service -n multiarch -o json | jq -r '.status.loadBalancer.ingress[].hostname')
for i in {1..8}; do curl -m3 $ELB ; echo; done
```
{{% notice tip %}} 
Si lo deseas, puedes copiar y pegar el DNS del balanceador de cargas en tu navegador para ver la aplicación en ejecución.
{{% /notice %}}

{{% notice note %}}
Es importante resaltar que estamos utilizando un único tag con Amazon ECR y Amazon EKS y esto nos da soporte multi-arquitectura nativo para que la imagen de contenedor adecuada sea seleccionada automáticamente para cada nodegroup. 
{{% /notice %}}

### Felicidades!!! Has implementado una aplicación multi-arquitectura en dos nodegroups utilizando instancias x86 y ARM64



Opcional: Puedes forzar una falla en el escenario al utilizar una imagen de docker de arquitectura única en vez de multi-arquitectura.
Escala hacia abajo la implementación actual a cero, cambia el tag de la imagen base para que apunte a una de arquitectura única y luego escala hacia arriba la implementaicón. Aquí los comandos:

```bash
kubectl -n multiarch scale deployment multiarch-deployment --replicas=0
kubectl -n multiarch set image deployment/multiarch-deployment multiarch-container=$CONTAINER_URI-x86
kubectl -n multiarch scale deployment multiarch-deployment  --replicas=4
```

Después de que la implementación se estabilice, ejecuta el siguiente comando para revisar el estatus:

```bash 
kubectl get pod -n multiarch 
```

Deberías poder ver algo similar a lo mostrado aquí, en donde solo dos pods se reportan como "Running" (en ejecución) y otros dos muestran un estatus "CrashLoopBackOff" o "Error".

```bash
NAME                                    READY   STATUS             RESTARTS   AGE
multiarch-deployment-857dbcdd7c-5455t   0/1     CrashLoopBackOff   6          9m33s
multiarch-deployment-857dbcdd7c-l48zd   1/1     Running            0          9m33s
multiarch-deployment-857dbcdd7c-ptf65   1/1     Running            0          9m33s
multiarch-deployment-857dbcdd7c-xk8vh   0/1     CrashLoopBackOff   6          9m33s
```










