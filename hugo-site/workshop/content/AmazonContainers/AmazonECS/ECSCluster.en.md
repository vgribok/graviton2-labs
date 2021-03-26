---
title: "AmazonECS : Deploy Graviton2 ECS cluster"
date: 2020-04-10T11:14:51-06:00
weight: 80
---

![ECS Logo](/images/ecs.png)

Amazon Elastic Container Service (Amazon ECS) is a highly scalable, fast container management service that makes it easy to run, stop, and manage containers on a cluster. 
Your containers are defined in a task definition that you use to run individual tasks or tasks within a service. 
Amazon ECS enables you to launch and stop your container-based applications by using simple API calls. 
You can also retrieve the state of your cluster from a centralized service and have access to many familiar Amazon EC2 features.


{{% notice tip %}}
Make sure you complete Multi-architecture application build lab before starting this one. 
{{% /notice %}}


Start by reviewing the contents of the AmazonECS task definition in file graviton2-labs/graviton2/cs_graviton/ecs_graviton2.py

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

1. Deploy ECS cluster using CDK

```
cdk deploy GravitonID-ecs
```

2. Once the cluster and ECS task are available execute following commands to verify ELB endpoint for the service.

{{% notice note %}} 
It will take several minutes for the ELB to become healthy and start passing traffic to the pods. 
{{% /notice %}}


```bash
ECS_ELB=$(aws cloudformation describe-stacks --stack-name GravitonID-ecs --query "Stacks[0].Outputs[0].OutputValue" --output text)
```

3. Test the cluster and verify your service using Graviton2 instance type.

```bash
for i in {1..8}; do curl -m3 $ECS_ELB ; echo; done 

```

You now have a fully wowking ECS cluster using Graviton2 instace type that is ready to use.
