---
title: "Restore your snapshot to Graviton2 instance"
date: 2020-04-10T11:14:51-06:00
weight: 30
---


We're ready to restore our database to new Graviton2-based instance.
Start by reviewing contents of the RDS MySQL 8 database definition in file graviton2_labs/rds_graviton/ds_restore.py

```
        snapshot_id = ssm.StringParameter.value_for_string_parameter(self ,"graviton_rds_lab_snapshot")
        g2_db_mysql8 = rds.DatabaseInstanceFromSnapshot(self, "GravitonMySQL",
                                             engine=rds.DatabaseInstanceEngine.mysql(
                                                 version=rds.MysqlEngineVersion.VER_8_0_21
                                             ),
                                             instance_type=ec2.InstanceType("m6g.4xlarge"),
                                             snapshot_identifier=snapshot_id,
                                             vpc=vpc,
                                             multi_az=False,
                                             publicly_accessible=True,
                                             allocated_storage=100,
                                             storage_type=rds.StorageType.IO1,
                                             iops=5000,
                                             cloudwatch_logs_exports=["error", "general", "slowquery"],
                                             enable_performance_insights=True,
                                             deletion_protection=False,
                                             delete_automated_backups=True,
                                             backup_retention=core.Duration.days(1),
                                             vpc_subnets={
                                                 "subnet_type": ec2.SubnetType.PUBLIC
                                             },
                                             parameter_group=rds.ParameterGroup.from_parameter_group_name(
                                                 self, "para-group-mysql",
                                                 parameter_group_name="default.mysql8.0"
                                             )
                                             )
```
1. We'll use the snapshot we created from original x86 instance to restore new Graviton2 database.
Execute following command to create a new Graviton2 instance:

```bash

cdk deploy GravitonID-rds-restore
```

2. Before we connect to the Graviton2 MySQL instance, we need to update the username and password as environment variables in our Cloud9 session. 
We will use CloudFormation output to find relevant variables.

```bash
CREDS=$(aws secretsmanager get-secret-value --secret-id `aws cloudformation describe-stacks --stack-name GravitonID-rds-8 --query "Stacks[0].Outputs[0].OutputValue" --output text` | jq -r '.SecretString')
export DBUSER="`echo $CREDS | jq -r '.username'`"
export DBPASS="`echo $CREDS | jq -r '.password'`"
export DBPORT="`echo $CREDS | jq -r '.port'`"
export DBHOST=$(aws rds describe-db-instances --db-instance-identifier `aws cloudformation describe-stacks --stack-name GravitonID-rds-restore --query "Stacks[0].Outputs[0].OutputValue" --output text` | jq -r '.DBInstances[] | .Endpoint.Address')
echo $DBUSER
echo $DBPASS
echo $DBHOST
echo $DBPORT
```

3. After you have done this, please connect to your MySQL instance. Run the following command to connect to your MySQL instance:

```bash
mysql -h $DBHOST -P $DBPORT -u$DBUSER -p$DBPASS
```

4. Verify the employees table checksum on Graviton2 instance by running below command in mysql client:

```bash
use employees; checksum table employees;
```

You should see the output similar to one below. Please compare checksum value with one from original 
database.

```
+---------------------+-----------+
| Table               | Checksum  |
+---------------------+-----------+
| employees.employees | 610052939 |
+---------------------+-----------+
1 row in set (0.24 sec)
```

5. Exit MySQL client

### At this point you have a fully functional copy of your original database using Amazon RDS and Graviton2 M6g instace type.
