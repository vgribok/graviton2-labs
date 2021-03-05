---
title: "AmazonEKS : Running ASP.NET Core application on Graviton2"
date: 2020-04-10T11:14:51-06:00
weight: 45
---

One of the great strengths of the .NET Core platform .NET 5 is signifcant improvement in runtime performance and that .NET is ready 
for scalable modernization efforts. 
Customers can also choose to build their .NET Core platform with AWS purpose-built AWS Graviton2 Processor. 
AWS is the only major cloud provider that enables .NET 5 an ARM64 architecture option today. Amazon EC2 instances 
running AWS Graviton2 provide up to 40% better price performance over comparable current generation x86-based instances. 
AWS Graviton2 helps customers running .NET realize ARM64 performance improvements with all .NET 5 Linux 
supported distributions (Alpine Linux, Debian, and Ubuntu).

{{% notice tip %}} 
Make sure you complete AmazonEKS : "Deploy multi-architecture EKS cluster" lab before starting this one. 
{{% /notice %}}

Start by reviewing CDK stack responsible for deploying .NET Core build pipeline in graviton2-labs/graviton2/cs_graviton/pipeline_netcore_graviton2.py file.


        docker_build_arm64 = codebuild.PipelineProject(
            scope=self,
            id=f"DockerBuild_ARM64",
            environment=dict(
                build_image=codebuild.LinuxBuildImage.AMAZON_LINUX_2_ARM,
                privileged=True),
            environment_variables={
                'REPO_ECR': codebuild.BuildEnvironmentVariable(
                    value=container_repository.repository_uri),
            },
            build_spec=buildspec_arm64
        )

1. Deploy a .NET Core build pipeline using CDK

```bash
cd ~/environment/graviton2-labs/
cdk deploy GravitonID-pipeline-dotnet

```

2. Clone .NET Core samples git repository by executing : 

```bash
git clone https://github.com/dotnet/dotnet-docker.git
```

3. Clone .NET Core Code Commit git repository by executing : 

```bash 
git clone `aws cloudformation describe-stacks --stack-name GravitonID-pipeline-dotnet --query "Stacks[0].Outputs[0].OutputValue" --output text`
```

4. Copy code build specification files and .Net Core 5 application source code to the new git repo.

```bash
cp -r dotnet-docker/samples/aspnetapp/*  graviton2-aspnet-lab/
cp dotnet-docker/samples/aspnetapp/Dockerfile.debian-arm64 graviton2-aspnet-lab/Dockerfile
cp graviton2/cs_graviton/arm64-dotnet-buildspec.yml graviton2-aspnet-lab/
```

5. Execute below commands to commit and push changes to CodeCommit repository.

```bash
cd ~/environment/graviton2-labs/graviton2-aspnet-lab/
git add .
git commit -m ".Net Core 5 ASP Net Sample First Commit"
git push
```
This will trigger  
*  build of docker image of .Net Core 5 application for arm64 architectures
*  Push of .Net Core 5 application  docker images to ECS repository

6. Monitor CodePipeline steps using AWS Console by opening this link in a new tab. Remember to choose the right AWS region. https://console.aws.amazon.com/codesuite/codepipeline/pipelines/

7. When the all steps of CodePipeline are successful return to Cloud9 environment and execute the following command to set environment variables for deployemnt.


```bash 
export NET_REPO_URI=$(aws ecr describe-repositories --repository-name graviton2-aspnet-lab  | jq -r '.repositories[0].repositoryUri')
export NET_IMAGE_TAG=$(aws ecr describe-images --repository-name graviton2-aspnet-lab --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' | jq -r .)
export NET_CONTAINER_URI=$NET_REPO_URI:$NET_IMAGE_TAG
echo $NET_REPO_URI
echo $NET_IMAGE_TAG
echo $NET_CONTAINER_URI
aws ssm put-parameter --name "graviton_net_container_uri" --value $NET_CONTAINER_URI --type String --overwrite 

```

8. Deploy .Net Core application to EKS cluster 

```bash
cd ~/environment/graviton2-labs/
cat graviton2/cs_graviton/Deployment-aspnet.yaml | sed "s#{{container_uri}}#$NET_CONTAINER_URI#" | kubectl apply -f -
```

9. You can ckeck the status of your deployment by executing:

```bash
kubectl get svc,deployment,po -n aspnet
```

10. Access .Net Core application via LoadBalancer endpoint 

{{% notice tip %}} 
It will take several minutes for the ELB to become healthy and start passing traffic to the pods. 
{{% /notice %}}

```bash
NET_ELB=$(kubectl get service aspnet-service -n aspnet -o json | jq -r '.status.loadBalancer.ingress[].hostname')
echo $NET_ELB 
```
Copy and paste the loadBalancer dns name into your browser and see the application running. 

### Congratulations! Now you have deployed .Net Core 5 application using Elastic Kubernetes Service and ARM64 instance types.
