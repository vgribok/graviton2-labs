---
title: "AmazonEKS : Ejecutando aplicaciones hechas en ASP.NET Core sobre Graviton2"
date: 2020-04-10T11:14:51-06:00
weight: 45
---

Una de las grandes fortalezas de la plataforma .NET Core es que .NET 5 tiene mejoras significativas en rendimiento y está listo 
para esfuerzos de modernización escalables.
Los clientes pueden también elegir construir sus aplicaciones hechas en .NET Core utilizando el procesador AWS Graviton2. 
AWS es el único proveedor de nube que ofrece la opción de ejecutar cargas de trabajo en .NET sobre arquitecturas ARM64 
Las instncias EC2 que son ejecutadas con AWS Graviton2 proveen hasta un 40% en mejora de precio/rendimiento sobre generaciones actuales de instancias basadas en x86.
Los procesadores Graviton2 ayudan a los clientes a darse cuenta de la mejora significativa de rendimiento de sus aplicaciones creadas en .NET sobre distribuciones soportadas de linux (Alpine Linux, Debian, and Ubuntu).

{{% notice tip %}} 
Asegúrate de haber completado el laboratorio "AmazonEKS : Creación de un cluster EKS multi-arquitectura" antes de iniciar este. 
{{% /notice %}}

Inicia revisando el stack de CDK responsable por implementar el pipeline de construcción de .NET Core en el archivo: graviton2-labs/graviton2/cs_graviton/pipeline_netcore_graviton2.py .


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

1. Implementa el pipeline utilizando CDK:

```bash
cd ~/environment/graviton2-labs/
cdk deploy GravitonID-pipeline-dotnet

```

2. Clona el repositorio ejemplo de .NET de git:

```bash
git clone https://github.com/dotnet/dotnet-docker.git
```

3. Clona el repositorio de .NET Core de CodeCommit: 

```bash 
git clone `aws cloudformation describe-stacks --stack-name GravitonID-pipeline-dotnet --query "Stacks[0].Outputs[0].OutputValue" --output text`
```

4. Copia los archivos de especificación de code build y la aplicación ejemplo de .NET Core 5 al nuevo repositorio git:

```bash
cp -r dotnet-docker/samples/aspnetapp/*  graviton2-aspnet-lab/
cp dotnet-docker/samples/aspnetapp/Dockerfile.debian-arm64 graviton2-aspnet-lab/Dockerfile
cp graviton2/cs_graviton/arm64-dotnet-buildspec.yml graviton2-aspnet-lab/
```

5. Ejecuta los comandos siguientes para hacer commit y subir los cambios al repositorio de CodeCommit:

```bash
cd ~/environment/graviton2-labs/graviton2-aspnet-lab/
git add .
git commit -m ".Net Core 5 ASP Net Sample First Commit"
git push
```
Esto inicializará   
*  la construcción de la imagen de docker basada en .NET Core 5 y arquitectura ARM64
*  Subirá la imagen de docker al repositorio de ECR.

6. Monitorea los pasos del pipeline en CodePipeline utilizando la consola de AWS. Puedes ir directo a esta vista dando clic en la siguiente liga: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/graviton2-pipeline-lab/view?region=us-east-1

7. Cuando todos los pasos del pipeline en CodePipeline hayan sido marcados como exitosos, regresa al ambiente de Cloud9 y ejecuta lo siguientes comandos para configurar las variables de ambiente para la implementación


```bash 
export NET_REPO_URI=$(aws ecr describe-repositories --repository-name graviton2-aspnet-lab  | jq -r '.repositories[0].repositoryUri')
export NET_IMAGE_TAG=$(aws ecr describe-images --repository-name graviton2-aspnet-lab --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' | jq -r .)
export NET_CONTAINER_URI=$NET_REPO_URI:$NET_IMAGE_TAG
echo $NET_REPO_URI
echo $NET_IMAGE_TAG
echo $NET_CONTAINER_URI
aws ssm put-parameter --name "graviton_net_container_uri" --value $NET_CONTAINER_URI --type String --overwrite 

```

8. Implementa la aplicación hecha en .NET Core 5 en el cluster de EKS

```bash
cd ~/environment/graviton2-labs/
cat graviton2/cs_graviton/Deployment-aspnet.yaml | sed "s#{{container_uri}}#$NET_CONTAINER_URI#" | kubectl apply -f -
```

9. Puedes revisar el estatus de tu implementación ejecutando:

```bash
kubectl get svc,deployment,po -n aspnet
```

10. Accede a la aplicación utilizando el DNS del Balanceador de carga (ELB)

{{% notice tip %}} 
Tomará varios minutos para que el balanceador de carga pase a estatus "saludable" y comience a enviarle tráfico a los pods. 
{{% /notice %}}

```bash
NET_ELB=$(kubectl get service aspnet-service -n aspnet -o json | jq -r '.status.loadBalancer.ingress[].hostname')
echo $NET_ELB 
```
Copia y pega el nombre de DNS del balanceador de carga en tu navegador. Deberás poder ver la aplicación en ejecución.

### Felicidades!!! Implementaste una aplicación hecha en .NET Core usando Amazon EKS + instancias Graviton2.
