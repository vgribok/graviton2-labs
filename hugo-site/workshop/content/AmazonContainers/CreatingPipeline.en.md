---
title: "Create container build pipeline"
date: 2020-04-10T11:14:51-06:00
weight: 10
---

We will start by creating a pipeline for building multi-architecture container images. Creating images for both x86 and arm64 architectures will allow us 
to explore native multi-architecture support in AWS services and freely choose between the most optimal compute option for the workload.

The CDK stack you will deploy will create a source code repository for the NodeJS application and two build steps to create container images for x86 and arm64 architectures.
1. Start by reviewing the contents of the CDK stack definition in file graviton-labs/graviton2/cs_graviton/pipeline_graviton2.py for both architectures.

{{% notice note %}}
In order to build multi-architecture images we are not using any emulation layer. Instead we use both x86 and arm64 build instances 
to ensure we build our containers on native architectures.
{{% /notice %}}

x86 container build : 
```
        docker_build_x86 = codebuild.PipelineProject(
            scope=self,
            id=f"DockerBuild_x86",
            environment=dict(
                build_image=codebuild.LinuxBuildImage.AMAZON_LINUX_2_3,
                privileged=True),
            environment_variables={
                'REPO_ECR': codebuild.BuildEnvironmentVariable(
                    value=container_repository.repository_uri),
            },
            build_spec=buildspec_x86
        )
```
arm64 container build : 
```
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
```

After successful build the continer images will be pushed to dedicated Elastic Container Registy (ECR) with tags 
following <COMMIT_HASH>:<ARCH> pattern.
At this point, you could pull these images by referring to their architecture-specific tags

{{% notice tip %}}We will simplify this process by creating a docker multi-arch manifest list and pushing it to Amazon ECR.
{{% /notice %}}

The end-to-end container build will match the diagram below. 

2. Initiate the pipeline deployment by issuing command: 
```bash
cdk deploy GravitonID-pipeline
```
3. Once the multi-architecture build pipeline is deployed you can proceed to the next step where we build containers for x86 and arm64 version of NodeJS application. 



