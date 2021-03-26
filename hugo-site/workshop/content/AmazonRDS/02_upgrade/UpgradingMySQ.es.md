---
title: "Actualizando la version del motor de MySQL RDS"
date: 2020-04-10T11:14:51-06:00
weight: 30
---

Cuando Amazon RDS soporte nuevas versiones de un motor de bases de datos podrás comenzar con el proceso de actualización de instancias de bases de datos.
Existen dos tipos de actializaciones para instancias de bases de datos con MySQL: major version upgrades y minor version upgrades.

Major version upgrades o actualizaciones de version mayores pueden contener cambios en el motor que no permiten tener retrocompatibilidad con versiones o aplicaciones anteriores. Como resiltando de esto, estos cambios deberan de ejecutarse de forma manual en tus instancias de bases de datos y puedes hacerlos al modificar tu instancia de bases de datos.

En este laboratorio te guaremos en los pasos que debes seguir para hacer la actualizacion de tu motor de MySQL para tu instancia de RDS. Estas operaciones se realizaran desde tu ambiente de Cloud9 usando la linea de comando de AWS pero es importante que sepas que tambien puedes realizarlas desde la consola de AWS o realizando llamados al API modify-db-instance.

{{% notice warning %}} 
Te recomendamos que pruebes cualquier cambio antes de realizarlo en instancias productivas, de modo que puedas entender perfectamente el impacto de cada cambio.
{{% /notice %}}

1. Inicia el proceso de actualización de un major version upgrade process ejecutando el siguiente código en tu ambiente de Cloud9:

```
aws rds modify-db-instance --db-instance-identifier `aws cloudformation describe-stacks --stack-name GravitonID-rds-5 --query "Stacks[0].Outputs[1].OutputValue" --output text` --engine-version 8.0.21 --allow-major-version-upgrade  --apply-immediately
```

2. Monitorea el proceso de actualización de tu base de datos desde la Consola de AWS o con el siguiente código:

```bash 
aws rds describe-db-instances --db-instance-identifier $DBID | jq -r .DBInstances[0].DBInstanceStatus
```

3. Una vez que el proceso de actualización finalice y tu base de datos tenga el estado de "Availabe" conectate a un instancia de MySQL que acabas de actualizar con el siguiente comando:

```bash
mysql -h $DBHOST -P $DBPORT -u$DBUSER -p$DBPASS
```

4. Verifica que la tabla de empleados en Graviton2 sea correcta ejecutando el checksum:

```bash
use employees; checksum table employees;
```

5. El resultado será una tabla similar a la de abajo. Compara estos resultados con el checksum original que escribiste en el capitulo anterior

```
+---------------------+-----------+
| Table               | Checksum  |
+---------------------+-----------+
| employees.employees | 610052939 |
+---------------------+-----------+
1 row in set (0.24 sec)
```

6. Sal del cliente de MySQL
