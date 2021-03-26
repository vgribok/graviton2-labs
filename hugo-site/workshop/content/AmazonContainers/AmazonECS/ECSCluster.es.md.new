---
title: "AmazonECS : Implementando un cluster de ECS con instancias Graviton2"
date: 2020-04-10T11:14:51-06:00
weight: 80
---

![ECS Logo](/images/ecs.png)

Amazon Elastic Container Service (Amazon ECS) es un servicio de manejo de contenedores altamente escalable y rápido que hace sencilla la ejecución, escalabilidad y el manejo de contenedores en un cluster. 
Tus contenedores están definidos en una "definición de tarea" que utilizarás para ejecutar "tareas" individuales o "tareas" como parte de un "servicio".
Amazon ECS te permite inicializar y detener tus aplicaciones basadas en contenedires utilizando llamadas de API muy simples. 
Además, puedes conocer el estado de tu cluster desde un servicio centralizado y tienes acceso a muchas características de Amazon EC2 y VPC.


{{% notice tip %}} 
Asegúrate de completar el laboratorio "Construcción multi-arquitectura de la aplicación" antes de iniciar esta sección. 
{{% /notice %}}


Comienza revisando el contenido de la "definición de tarea" en el archivo: graviton2-labs/graviton2/cs_graviton/ecs_graviton2.py

```bash

        ecs_ami = ecs.EcsOptimizedAmi(generation=ec2.AmazonLinuxGeneration.AMAZON_LINUX_2,
                                                             hardware_type=ecs.AmiHardwareType.ARM)
                                                                                
        asg_ecs = cluster.add_capacity("G2AutoScalingGroup",
                         instance_type=ec2.InstanceType("m6g.2xlarge"),
                         machine_image=ecs_ami
                         
        )

        container = task_definition.add_container(
            "web",
            image=ecs.ContainerImage.from_registry("{{container_uri}}"),
            memory_limit_mib=512,
            logging=ecs.LogDrivers.firelens(
                options={
                    "Name": "cloudwatch",
                    "log_key": "log",
                    "region": "us-east-1",
                    "delivery_stream": "my-stream",
                    "log_group_name": "firelens-fluent-bit",
                    "auto_create_group": "true",
                    "log_stream_prefix": "from-fluent-bit"}
            )    
        )
```

1. Crea el cluster de ECS utilizando Amazon CDK

```
cdk deploy GravitonID-ecs
```

2. Una vez el cluster y la "tarea" en Amazon ECS se encuentre disponible, ejecuta los siguientes comandos para verificar el endpoint de DNS del balanceador de carga asociado (Amazon ELB).

{{% notice note %}} 
Tomará varios minutos para que el balanceador de carga pase a estatus "saludable" y comience a enviarle tráfico a las "tareas". 
{{% /notice %}}


```bash
ECS_ELB=$(aws cloudformation describe-stacks --stack-name GravitonID-ecs --query "Stacks[0].Outputs[0].OutputValue" --output text)
```

3. Prueba el clúster y verifica que tu servicio esté utilizando una instancia Graviton2.

```bash
for i in {1..8}; do curl -m3 $ECS_ELB ; echo; done 

```

Ahora tienes un cluster de ECS funcionando con instancias Graviton2!
