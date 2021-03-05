---
title: "Multi-architecture application build"
date: 2020-04-10T11:14:51-06:00
weight: 20
---


1. Before we start this lab, please make sure you are working in your graviton2-labs folder. 
If you are not, please change to the folder by executing the following command in your bash shell :

```bash
cd ~/environment/graviton2-labs/
```

2. Clone an empty CodeCommit repo by executing : 

```bash
git clone `aws cloudformation describe-stacks --stack-name GravitonID-pipeline --query "Stacks[0].Outputs[0].OutputValue" --output text`               
```

3. Copy code build specification files and NodeJS application source code to the new git repo.

```bash
cp -r graviton2/cs_graviton/app/* graviton2-pipeline-lab/
```

4. Execute below commands to commit and push changes to CodeCommit repository.

```bash
cd graviton2-pipeline-lab
git add .
git commit -m "First commit Node.js sample application."
git push
```
This will trigger  
*  build of docker images for both x86 and arm64 architectures
*  build of docker image with multi-architecture manifest
*  a push of all docker images to ECS repository

5. Monitor CodePipeline steps using AWS Console by opening this link in a new tab. https://console.aws.amazon.com/codesuite/codepipeline/pipelines/graviton2-pipeline-lab/view?region=us-east-1

6. When all steps of CodePipeline are successful, execute the following commands to set environment variables:

```bash 
export ECR_REPO_URI=$(aws ecr describe-repositories --repository-name graviton2-pipeline-lab  | jq -r '.repositories[0].repositoryUri')
export MULTI_IMAGE_TAG=$(aws ecr describe-images --repository-name graviton2-pipeline-lab --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags[0]' | jq -r .)
export CONTAINER_URI=$ECR_REPO_URI:$MULTI_IMAGE_TAG
echo $ECR_REPO_URI
echo $MULTI_IMAGE_TAG
echo $CONTAINER_URI
aws ssm put-parameter --name "graviton_lab_container_uri" --value $CONTAINER_URI --type String --overwrite 

```
