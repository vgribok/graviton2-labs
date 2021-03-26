---
title: "Construcción multi-arquitectura de la aplicación"
date: 2020-04-10T11:14:51-06:00
weight: 20
---


1. Antes de iniciar este laboratorio, por favor asegúrate de trabajar en la carpeta graviton2-labs. 
Si no estas ahí, cámbiate a esa carpeta ejecutando el siguiente comando en tu terminal:

```bash
cd ~/environment/graviton2-labs/
```

2. Clona un repositorio vacío de CodeCommit ejecutando: 

```bash
git clone `aws cloudformation describe-stacks --stack-name GravitonID-pipeline --query "Stacks[0].Outputs[0].OutputValue" --output text`               
```

3. Copia los archivos de especificación de code build y el código fuente de la aplicación hecha en NodeJS hacia el nuevo repositorio de CodeCommit.

```bash
cp -r graviton2/cs_graviton/app/* graviton2-pipeline-lab/
```

4. Ejecuta los comandos siguientes para hacer commit y subir los cambios al repositorio de CodeCommit.

```bash
cd graviton2-pipeline-lab
git add .
git commit -m "First commit Node.js sample application."
git push
```
Esto inicializará
*  la creación de la imagen de docker tanto para arquitectura x86 como para arm64
*  la creación del manifest multi-arquitecturade las imagenes de docker
*  la carga de las imagenes de docker y el manifes al repositorio en Amazon ECR.

5. Monitorea los pasos del pipeline en CodePipeline utilizando la consola de AWS. Puedes ir directo a esta vista dando clic en la siguiente liga: https://console.aws.amazon.com/codesuite/codepipeline/pipelines/graviton2-pipeline-lab/view?region=us-east-1

6. Cuando todos los pasos del pipeline en CodePipeline hayan sido marcados como exitosos, ejecuta los siguientes comandos para configurar las variables de ambiente:

```bash 
export ECR_REPO_URI=$(aws ecr describe-repositories --repository-name graviton2-pipeline-lab  | jq -r '.repositories[0].repositoryUri')
export MULTI_IMAGE_TAG=$(aws ecr describe-images --repository-name graviton2-pipeline-lab --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' | jq -r .)
export CONTAINER_URI=$ECR_REPO_URI:$MULTI_IMAGE_TAG
echo $ECR_REPO_URI
echo $MULTI_IMAGE_TAG
echo $CONTAINER_URI
aws ssm put-parameter --name "graviton_lab_container_uri" --value $CONTAINER_URI --type String --overwrite 

```
