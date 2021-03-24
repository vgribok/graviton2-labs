---
title: Import Sample Database
date: 2020-04-10T11:14:51-06:00
weight: 20
---

1. Before we start this lab, please make sure you are working in your graviton2-labs folder. 
If you are not, please change to the folder by executing the following command in your bash shell :

```bash
cd ~/environment/graviton2-labs/
```

We'll start by cloning a sample database for MySQL. 

```bash 
git clone https://github.com/datacharmer/test_db.git
cd test_db
```

2. After you have done this, please connect to your MySQL instance. Run the following command to connect to your MySQL instance:

```bash
mysql -h $DBHOST -P $DBPORT -u$DBUSER -p$DBPASS
```

If you are experiencing log in issues due to the lack of environment variables, please use the following commands to set the credentials. 

```bash
CREDS=$(aws secretsmanager get-secret-value --secret-id `aws cloudformation describe-stacks --stack-name GravitonID-rds-8 --query "Stacks[0].Outputs[0].OutputValue" --output text` | jq -r '.SecretString')
export DBUSER="`echo $CREDS | jq -r '.username'`"
export DBPASS="`echo $CREDS | jq -r '.password'`"
export DBHOST="`echo $CREDS | jq -r '.host'`"
export DBPORT="`echo $CREDS | jq -r '.port'`"
echo $DBUSER
echo $DBPASS
echo $DBHOST
echo $DBPORT
```



3. If you are logged in to your MySQL instance you can load a sample database to your RDS instance. 
To load the date  into the database, run the following command from your MySQL client. 

```bash
source employees.sql
```

The engine should start loading the data on its own and you should see outputs similar to:
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

4. Verify the employees table checksum by running :

```bash
use employees; checksum table employees;
```

You should see the output similar to one below. Please write down the checksum value for original 
database table checksum.

```
+---------------------+-----------+
| Table               | Checksum  |
+---------------------+-----------+
| employees.employees | 610052939 |
+---------------------+-----------+
1 row in set (0.24 sec)
```

5. Exit MySQL client and create database snapshot by executing following command:

```bash
cd ~/environment/graviton2-labs/
 ~/environment/graviton2-labs/scripts/rds-snapshot.sh 
```
The script will return a randomly generated snapshot id.

6. Please monitor the snapshot progress using AWS console or by executing following command :

```bash 
aws rds describe-db-snapshots --db-snapshot-identifier `aws ssm get-parameter --name "graviton_rds_lab_snapshot" | jq -r .Parameter.Value` | jq -r .DBSnapshots[0].Status
```
7. When snapshot status changes to "available" you can procedd to the next chapter.


