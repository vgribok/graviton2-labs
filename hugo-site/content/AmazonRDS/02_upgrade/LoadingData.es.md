---
title: Importar Datos de prueba a MySQL
date: 2020-04-10T11:14:51-06:00
weight: 20
---

1. Antes de iniciar este laboratorio, asegurate de estar en el directorio graviton2-labs. Si noe estas ahí ejecuta este comando en la terminal de Cloud9:

```bash
cd ~/environment/graviton2-labs/
```

Clona la base de datos de ejemplo de MySQL.

```bash 
git clone https://github.com/datacharmer/test_db.git
cd test_db
```

2. Al terminar, conectate a tu instancia de MySQL ejecutando el siguiente comando:

```bash
mysql -h $DBHOST -P $DBPORT -u$DBUSER -p$DBPASS
```

Si experimentas problemas en la conneción debido a la falta de las variables de ambiente ejecuta el siguiente código para configurar las credenciales. 

```bash
CREDS=$(aws secretsmanager get-secret-value --secret-id `aws cloudformation describe-stacks --stack-name GravitonID-rds-5 --query "Stacks[0].Outputs[0].OutputValue" --output text` | jq -r '.SecretString')
export DBUSER="`echo $CREDS | jq -r '.username'`"
export DBPASS="`echo $CREDS | jq -r '.password'`"
export DBHOST="`echo $CREDS | jq -r '.host'`"
export DBPORT="`echo $CREDS | jq -r '.port'`"
echo $DBUSER
echo $DBPASS
echo $DBHOST
echo $DBPORT
```

3. Una vez conectado a tu instancia de MySQL carga una muestra de datos a tu instancia RDS. Para cargar datos ejecuta este comando desde el cliente de MySQL.

```bash
source employees.sql
```

El motor comenzará a cargar los datos y verás una salida similar a esta:

```
Query OK, 7671 rows affected (0.05 sec)
Records: 7671  Duplicates: 0  Warnings: 0

+---------------------+
| data_load_time_diff |
+---------------------+
| 00:00:33            |
+---------------------+
1 row in set (0.00 sec)

mysql> 
```

4. Verifica que la tabla de empleados sea correcta ejecutando el checksum:

```bash
use employees; checksum table employees;
```

El resultado será una tabla similar a la de abajo. Escribe los valores originales en un archivo para poder compararlos más tarde.

```
+---------------------+-----------+
| Table               | Checksum  |
+---------------------+-----------+
| employees.employees | 610052939 |
+---------------------+-----------+
1 row in set (0.24 sec)
```

5. Sal del cliente de MySQL.

Asegurate de escribir los resultados de checksum original de la tabla de MySQL 5.
Avanza al siguiente laboratorio "Actualizando la version del motor de MySQL RDS".
