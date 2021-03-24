---
title: "Cambiando el tipo de instancia a Graviton2"
date: 2020-04-10T11:14:51-06:00
weight: 40
---

Puedes cambiar la configuración de la instancia de la base de datos y agregar almacenamiento adicional o cambiar el tipo de la instancia.
Esto incluye cambiar de una instancia con arquitectura x86 a un tipo de instancia con Graviton2 y arquitectura arm.

Te recomendamos que pruebes cualquier cambio en instancias de prueba antes de hacer cambios a una productiva de manera que entiendas perfectamente el impacto de cualquier cambio. Como se menciona en el capitulo anterior, realizar estas pruebas es importante cuando se actualizan versiones del motor de bases de datos.

La mayoria de las modificaciones a una instancia de bases de datos pueden aplicar inmediatamente o pueden ser aplicadas en la siguiente ventana de mantenimiento y podrás hacer la que sea más conveniente para tí.


1. Inicia el proceso de cambiar el tipo de la instancia ejecutando el siguiente código en tu ambiente de Cloud9:
 
```

aws rds modify-db-instance --db-instance-identifier `aws cloudformation describe-stacks --stack-name GravitonID-rds-5 --query "Stacks[0].Outputs[1].OutputValue" --output text` --db-instance-class db.m6g.4xlarge --allow-major-version-upgrade --apply-immediately

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

Consulta la documentación https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html para obtener más detalles sobre la modificación de instancias de bases de datos en RDS.
