---
title: "Introducción"
date: 2020-04-10T11:14:49-06:00
weight: 10
---

Estos primeros pasos se enfocan en configurar todos los prerequisitos para el laboratorio de Graviton 2. Con este proposito utilizaremos los siguientes servicios de AWS:

* [Cloud9 IDE](https://aws.amazon.com/cloud9/) (Integrated Development Environment)
* [AWS CDK](https://docs.aws.amazon.com/cdk/latest/guide/home.html) (Cloud Development Kit)
  
Con [AWS CDK](https://docs.aws.amazon.com/cdk/latest/guide/home.html) principalmente configuraremos infraestructura estatica y algunos otros prerequisitos.  


### Set up a Cloud9 IDE


1. En la consola de AWS, ve al servicio de Cloud9 y selecciona la opción `Create environment`. Nombra tu nuevo IDE como `Graviton2IDE` y da click `Next Step`.  
En la siguiente ventana selecciona la opción "Other instance type" and elige el tipo de instancia `m5.xlarge`. DA click `Next step`.  
En la pagina final, da click en `Create environment`. Asegurate de dejar los valores predefinidos en la sección de configuración de conectividad.

Una vez que el ambiente sea construido y este activo serás automaticamente redireccionado al IDE. Toma unos minutos para explorar la interfaz. Podras cambiar el esquema de colores si lo deseas (AWS Cloud9 menu -> Preferences -> Themes).

Ahora vamos a actualizar Cloud9 para poder ejecutar los laboratorios desde tu IDE.

* Crea un nuevo rol para tu ambiente de Cloud9 dando click aquí [link](https://console.aws.amazon.com/iam/home#/roles$new?step=review&commonUseCase=EC2%2BEC2&selectedUseCase=EC2&policies=arn:aws:iam::aws:policy%2FAdministratorAccess).
* Confirma que el servicio de AWS EC2 esta seleccionado y da click en `Next: Permissions`.
* Revisa que el permiso `AdministratorAccess` esta seleccionado y da click en `Next: Tags`.
* Deja los valores predeterminados y da click en `Next: Review`, revisa que los parametros sean correctos.
* Nombra tu rol como `Cloud9-Admin-Role` y da click en `Create role`.

* Una vez que tu nuevo rol es creado ve al servicio de EC2, busca tu instancia de Cloud9, y asigna el rol a esta instancia (Actions -> Security -> Modify IAM role).
* Regresa al servicio de Cloud9 y en el menú `Preferences` y bajo la pestaña de 'AWS Credentials' deshabilita la opción `AWS managed temporary credentials`.

2. Avanza al siguiente paso del laboratorio "Prerequisitos".
