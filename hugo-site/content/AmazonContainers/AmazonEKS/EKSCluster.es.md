---
title: "AmazonEKS : Creación de un cluster EKS multi-arquitectura"
date: 2020-04-10T11:14:51-06:00
weight: 30
---

Amazon Elastic Kubernetes Service (Amazon EKS) es un servicio administrado que puedes utilizar para ejecutar Kubernetes en aws sin necesidad de instalar, operar y mantener tu propio plano de control o nodos de un clúster.
Kubernetes es un sistema de código abierto para automatizar la implementación, escalabilidad y orquestación de aplicaciones containerizadas.

1. Revisa el contenido del stack de CDK localizado en el archivo graviton-labs/graviton2/cs_graviton/eks_graviton2.py.
Este stack creará un cluster de EKS con dos nodegroups: un grupo para arquitectura x86 y otro para arquitectura ARM64

```
        self.cluster = eks.Cluster(self, "EKSGraviton2",
            version=eks.KubernetesVersion.V1_18,
            default_capacity=0,
            endpoint_access=eks.EndpointAccess.PUBLIC_AND_PRIVATE,
            vpc=vpc,
            security_group=eks_security_group

        )

        self.ng_x86 = self.cluster.add_nodegroup_capacity("x86-node-group",
            instance_types=[ec2.InstanceType("m5.large")],
            desired_size=2,
            min_size=1,
            max_size=3
        )
        
        self.ng_arm64 = self.cluster.add_nodegroup_capacity("arm64-node-group",
            instance_types=[ec2.InstanceType("m6g.large")],
            desired_size=2,
            min_size=1,
            max_size=3
        )
```

2. Implementa el cluster de EKS con los dos nodegroups utilizando CDK:

```
cdk deploy GravitonID-eks
```
{{% notice tip %}} 
Este proceso puede tardar de 15 a 20 minutos. Es una gran oportunidad de tomarte un descanso.
{{% /notice %}}

3. Una vez que el cluster y los nodegroups estén disponibles, ejecuta el siguiente comando para crear el archivo de configuración de kubectl:

```bash
`aws cloudformation describe-stacks --stack-name GravitonID-eks --query "Stacks[0].Outputs[1].OutputValue" --output text`
```

4. Prueba el cluster y verifica los nodos que lo componen:

```bash
kubectl get nodes --label-columns=kubernetes.io/arch
```
Deberías ver una salida similar a la descrita aquí. Cuatro nodos en total, de los cuales 2 utilizan instancias ARM64 basadas en Graviton2 y dos utilizan AMD64.
```
NAME                         STATUS   ROLES    AGE   VERSION              ARCH
ip-10-0-2-105.ec2.internal   Ready    <none>   10h   v1.18.9-eks-d1db3c   amd64
ip-10-0-2-193.ec2.internal   Ready    <none>   10h   v1.18.9-eks-d1db3c   arm64
ip-10-0-3-28.ec2.internal    Ready    <none>   10h   v1.18.9-eks-d1db3c   arm64
ip-10-0-3-58.ec2.internal    Ready    <none>   10h   v1.18.9-eks-d1db3c   amd64
```

Ahora tienes un cluster de EKS totalmente funcional que puede ejecutar aplicaciones hechas en múltiples arquitecturas.

5. Continua al siguiente paso
