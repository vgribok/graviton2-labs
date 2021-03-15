---
title: "Creating EMR Claster with Graviton2 instanaces"
weight: 10
---

1. Create S3 bucket for EMR jobs.

```bash
cd ~/environment/graviton2-labs
source scripts/create_emr_buckets.sh 
```

2. Execute following command to create EMR cluster in your default VPC.


```bash
export EMR_CLUSTER_ID=$(aws emr create-cluster --name test-emr-cluster --use-default-roles --release-label emr-6.1.0 --instance-count 3 --instance-type m6g.xlarge --applications Name=JupyterHub Name=Spark --ec2-attributes KeyName=graviton2key | jq -r '.ClusterId'); echo "Your cluster ID is = $EMR_CLUSTER_ID"
```

3. Authorize SSH connection from Cloud9 instance.

```bash
export C9_PRIVATEIP=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.privateIp')
export EMR_MASTER_SG=$(aws emr describe-cluster --cluster-id $EMR_CLUSTER_ID | jq -r '.Cluster | .Ec2InstanceAttributes | .EmrManagedMasterSecurityGroup')
export EMR_MASTER_IP=$(aws emr describe-cluster --cluster-id $EMR_CLUSTER_ID | jq -r '.Cluster | .MasterPublicDnsName')
aws ec2 authorize-security-group-ingress --group-id $EMR_MASTER_SG --protocol tcp --port 22 --cidr $C9_PRIVATEIP/32
```

4. Copy Spark ETL job to EMR Master node

```bash
scp scripts/etl-spark.py hadoop@$EMR_MASTER_IP:~/
```

5. Connect to EMR Master node and execute sparc job 

```bash
ssh hadoop@$EMR_MASTER_IP "spark-submit etl-spark.py s3://'$emr_s3_name'/input/ s3://'$emr_s3_name'/output/spark"  
```
When Spark job submitted through spark-submit on the command line, it shows up logs on the console. 

6. Wait few minutes and navigate to S3 service console to check  “output/spark” folder in your S3 bucket to see the results.
