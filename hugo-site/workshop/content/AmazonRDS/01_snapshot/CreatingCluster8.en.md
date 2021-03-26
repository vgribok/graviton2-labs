---
title: "Create RDS MySQL instance"
date: 2020-04-10T11:14:51-06:00
weight: 10
---

Start by reviewing contents of the RDS MySQL 8 CDK stack definition in file graviton2_labs/rds_graviton/rds_mysql_8.py

        db_mysql8 = rds.DatabaseInstance(self, "MySQL8",
                                             engine=rds.DatabaseInstanceEngine.mysql(
                                                 version=rds.MysqlEngineVersion.VER_8_0_21
                                             ),
                                             instance_type=ec2.InstanceType("m5.4xlarge"),
                                             vpc=vpc,
                                             multi_az=False,
                                             publicly_accessible=True,
                                             allocated_storage=100,
                                             storage_type=rds.StorageType.IO1,
                                             iops=5000,
                                             cloudwatch_logs_exports=["error", "general", "slowquery"],
                                             deletion_protection=False,
                                             enable_performance_insights=True,
                                             delete_automated_backups=True,
                                             backup_retention=core.Duration.days(1),
                                             parameter_group=rds.ParameterGroup.from_parameter_group_name(
                                                 self, "para-group-mysql",
                                                 parameter_group_name="default.mysql8.0"
                                             )
                                             )

Use of AWS Cloud Development Kit (CDK) greatly simplifies instantiation of AWS services such as Amazon RDS. 
Above Python code fragment allows you instantiate single-AZ RDS MySQL 8 instance with 100GB IO1 Amazon EBS volume.
This instance is using m5.4xlarge instance type and will be accessible onlyfrom your Cloud9 environment via public IP.
RDS instance created though CDK will also have simple backup policy, logging, and RDS Performance Insights enabled.

1. Initiate RDS MySQL 8 deployment using : 
```bash
cdk deploy GravitonID-rds-8
```

2. Before you connect to the MySQL instance, we need to set the username and password as environment variables in our Cloud9 session. 
We will use CloudFormation output to find relevant variables.

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

3. If you see an output of your username, password, host, and database port you have correctly set environment variables. 
Proceed to the next chapter "Import sample database". 

