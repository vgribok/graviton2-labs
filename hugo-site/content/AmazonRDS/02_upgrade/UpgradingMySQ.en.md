---
title: "Upgrading RDS MySQL database version"
date: 2020-04-10T11:14:51-06:00
weight: 30
---

When Amazon RDS starts supporting a new version of a database engine, you can upgrade your DB instances to the new version. 
There are two kinds of upgrades for MySQL DB instances: major version upgrades and minor version upgrades.

Major version upgrades can contain database changes that are not backward-compatible with existing applications. 
As a result, you must manually perform major version upgrades of your DB instances. 
You can initiate a major version upgrade by modifying your DB instance. 

In this exercise you will walk through the steps of upgrading your MySQL engine for your RDS instance. 
We will perform these operations from Cloud9 using AWS CLI, however you can achive the same results using 
AWS Console, or modify-db-instance API call.

{{% notice warning %}} 
We recommend that you test any changes on a test instance before modifying a production instance, 
so that you fully understand the impact of each change. 
{{% /notice %}}


1. Start major version upgrade process by executing following command in your Cloud9 environment :
 
```
aws rds modify-db-instance --db-instance-identifier `aws cloudformation describe-stacks --stack-name GravitonID-rds-5 --query "Stacks[0].Outputs[1].OutputValue" --output text` --engine-version 8.0.21 --allow-major-version-upgrade  --apply-immediately
```

2. You can monitor database upgrade process using AWS Console or CLI below
```bash 
aws rds describe-db-instances --db-instance-identifier $DBID | jq -r .DBInstances[0].DBInstanceStatus
```

3. Once the upgrade process finished and your database is in "availabe" connect to your upgraded MySQL instance by running the following command:

```bash
mysql -h $DBHOST -P $DBPORT -u$DBUSER -p$DBPASS
```


4. Verify the employees table checksum on Graviton2 instance by running :

```bash
use employees; checksum table employees;
```

5. You should see the output similar to one below. Please compare checksum value with one from original 
database.

```
+---------------------+-----------+
| Table               | Checksum  |
+---------------------+-----------+
| employees.employees | 610052939 |
+---------------------+-----------+
1 row in set (0.24 sec)
```

6. Exit MySQL client
