---
title: "Crear el pipeline de construcción del contenedor"
date: 2020-04-10T11:14:51-06:00
weight: 10
---

Comenzaremos creando un pipeline para construir imagenes de contenedor soportadas por múltiples arquitecturas. El crear imagenes tanto para arquitecturas x86 como para arm64 nos permitirán explorar el soporte nativo de los servicios de AWS para multi-arquitectura y nos permitirá movernos a la opción más óptima para nuestra carga de trabajo.

El stack de CDJ que implementarás creará un repositorio de códifo para la aplicación hecha en NodeJS y dos pasos de construcción para crear las imagenes de contenedor para arquitecturas x86 como para arm64.

1. Inicia revisando el contenido del stack de CDK en el archivo graviton-labs/graviton2/cs_graviton/pipeline_graviton2.py para ambas arquitecturas.

{{% notice note %}}
Para construir imagenes multi-arquitectura no estamos utilizando ninguna capa de emulación. Utilizamos instancias de construcción x86 y también arm64 para asegurarnos que la construcción sea nativa.
{{% /notice %}}

Construcción del contenedor en arquitectura x86 : 
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
Construcción del contenedor en arquitectura arm64 : 
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

Después de construir las imagenes de contenedor vamos a subirlas (push) a un repositorio de imagenes localizado en Amazon ECR con tags que siguen el patron <COMMIT_HASH>:<ARCH> .

En este punto tu puedes jalar (pull) estas imagenes refiriéndote al tag específico por arquitectura.

{{% notice tip %}}Simplificaremos este proceso creando un manifest de docker multi-arquitectura y subiéndolo al repositorio localizado en ECR.
{{% /notice %}}

La construcción de principio a fin de la imagen de contenedor está descrita en la imagen siguiente:

2. Inicializa la implementación del pipeline al ejecutar este comando: 
```bash
cdk deploy GravitonID-pipeline
```
3. Una vez que la construcción multi-arquitectura sea implementada, puedes proceder al siguiente paso en el que construiremos versiones de contenedores para x86 y arm64 de nuestra aplicaicón hecha en NodeJS. 



