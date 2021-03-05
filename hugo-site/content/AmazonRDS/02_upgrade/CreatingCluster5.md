---
title: "Create RDS MySQL instance"
date: 2020-04-10T11:14:51-06:00
weight: 10
---

Start by reviewing contents of the RDS MySQL 5 task definition in file labs/rds_graviton/rds_mysql_5.py

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

Use of AWS Cloud Development Kit (CDK) greatly simplifies instantiation of AWS services such as Amazon RDS. 
Above Python code fragment allows you instantiate single-AZ RDS MySQL 5 instance with 100GB GP2 Amazon EBS volume.
This instance is using m5.4xlarge instance type and will be accessible onlyfrom your Cloud9 environment via public IP.
RDS instance created though CDK will also have simple backup policy, logging, and RDS Performance Insights enabled.

1. Initiate RDS MySQL 5 deployment using : 

```bash
cdk deploy GravitonID-rds-5
```

2. Before we connect to the MySQL instance, we need to set the username and password as environment variables in our Cloud9 session. 
We will use CloudFormation output to find relevant variables.

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

3. If you see an output of your username, password, host, and database port you have correctly set environment variables.
Proceed to the next chapter "Import sample database". 
