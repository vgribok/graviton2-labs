---
title: "Changing instance to Graviton2"
date: 2020-04-10T11:14:51-06:00
weight: 40
---

You can change the settings of a DB instance to accomplish tasks such as adding additional storage or changing the DB instance class.
This includes switchin from x86 instances to Graviton2 instance type.

We recommend that you test any changes on a test instance before modifying a production instance, 
so that you fully understand the impact of each change. As mentioned in previous chapter,
testing is especially important when upgrading database versions.

Most modifications to a DB instance you can either apply immediately or defer until the next maintenance window.


1. Start instance type change process by executing following command in your Cloud9 environment :
 
```

aws rds modify-db-instance --db-instance-identifier `aws cloudformation describe-stacks --stack-name GravitonID-rds-5 --query "Stacks[0].Outputs[1].OutputValue" --output text` --db-instance-class db.m6g.4xlarge --allow-major-version-upgrade --apply-immediately

```

2. You can monitor database upgrade process using AWS Console or CLI below
```bash 
aws rds describe-db-instances --db-instance-identifier $DBID | jq -r .DBInstances[0].DBInstanceStatus
```
 
3. Once the upgrade process finished and your database is in "Availabe" connect to your upgraded MySQL instance by running the following command:

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




Please refer to https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html for more details on modifying RDS database instances.