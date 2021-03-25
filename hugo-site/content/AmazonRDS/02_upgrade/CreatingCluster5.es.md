---
title: "Crear la instancia de RDS MySQL"
date: 2020-04-10T11:14:51-06:00
weight: 10
---

Revisa los contenidos de la definición del task en RDS MySQL 5, encontraras el archivo en labs/rds_graviton/rds_mysql_5.py

        db_mysql5 = rds.DatabaseInstance(self, "MySQL5",
                                             engine=rds.DatabaseInstanceEngine.mysql(
                                                 version=rds.MysqlEngineVersion.VER_5_7_31
                                             ),
                                             instance_type=ec2.InstanceType("m5.4xlarge"),
                                             vpc=vpc,
                                             multi_az=False,
                                             publicly_accessible=True,
                                             allocated_storage=100,
                                             storage_type=rds.StorageType.GP2,
                                             cloudwatch_logs_exports=["audit", "error", "general", "slowquery"],
                                             deletion_protection=False,
                                             enable_performance_insights=True,
                                             delete_automated_backups=True,
                                             backup_retention=core.Duration.days(1),
                                             parameter_group=rds.ParameterGroup.from_parameter_group_name(
                                                 self, "para-group-mysql",
                                                 parameter_group_name="default.mysql5.7"
                                             )
                                             )

AWS Cloud Development Kit (CDK) simplifica la creación de servicios en AWS como por ejemplo crear instancias de Amazon RDS.
El fragmento de código escrito en Python de arriba te permite crear una instancia de RDS MySQL 5 con 100GB y un volumen Amazon EBS de tipo GP2 en una única zona de disponibilidad (single-AZ).
Esta instancia es de tipo m5.4xlarge y sólo podrás acceder a ella desde tu ambiente de Cloud9 environment a través de su IP pública.
La instancia RDS creada utilizando CDK también tendrá una politica de respaldos simple, generación de logs y la opción de Performance Insights activados.

1. Inicia la instancia RDS MySQL 5: 

```bash
cdk deploy GravitonID-rds-5
```

2. Antes de conectarte a la instancia de MySQL necesitas agregar el usuario y contraseña a las variables de ambiente en tu sessión de Cloud9.

```bash
CREDS=$(aws secretsmanager get-secret-value --secret-id `aws cloudformation describe-stacks --stack-name GravitonID-rds-5 --query "Stacks[0].Outputs[0].OutputValue" --output text` | jq -r '.SecretString')
export DBID=$(aws cloudformation describe-stacks --stack-name GravitonID-rds-5 --query "Stacks[0].Outputs[1].OutputValue" --output text)
export DBUSER="`echo $CREDS | jq -r '.username'`"
export DBPASS="`echo $CREDS | jq -r '.password'`"
export DBHOST="`echo $CREDS | jq -r '.host'`"
export DBPORT="`echo $CREDS | jq -r '.port'`"
echo $DBUSER
echo $DBPASS
echo $DBHOST
echo $DBPORT
echo $DBID
```

3. Si las variables de ambiente se configuraron correctamente en el resultado de la ejecución anterior podras ver tu usuario, password, host y base de datos.

Avanza al siguiente capitulo "Importar Datos de prueba a MySQL".
