---
title: "Creando un Cluster de Amazon EMR con instancias Graviton2"
weight: 10
---

1. Crea el bucket de s3 para los jobs de EMR

```bash
cd ~/environment/graviton2-labs
source scripts/create_emr_buckets.sh 
```

2. Ejecuta el siguiente comando para crear el clúster de EMR en tu VPC default


```bash
export EMR_CLUSTER_ID=$(aws emr create-cluster --name test-emr-cluster --use-default-roles --release-label emr-6.1.0 --instance-count 3 --instance-type m6g.xlarge --applications Name=JupyterHub Name=Spark --ec2-attributes KeyName=graviton2key | jq -r '.ClusterId'); echo "Your cluster ID is = $EMR_CLUSTER_ID"
```

3. Autoriza conexión ssh desde tu instancia de Cloud9

```bash
export C9_PRIVATEIP=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.privateIp')
export EMR_MASTER_SG=$(aws emr describe-cluster --cluster-id $EMR_CLUSTER_ID | jq -r '.Cluster | .Ec2InstanceAttributes | .EmrManagedMasterSecurityGroup')
export EMR_MASTER_IP=$(aws emr describe-cluster --cluster-id $EMR_CLUSTER_ID | jq -r '.Cluster | .MasterPublicDnsName')
aws ec2 authorize-security-group-ingress --group-id $EMR_MASTER_SG --protocol tcp --port 22 --cidr $C9_PRIVATEIP/32
```

4. Copia el job de ETL en Spark al nodo maestro de EMR

```bash
scp scripts/etl-spark.py hadoop@$EMR_MASTER_IP:~/
```

5. Conéctate al nodo maestro de EMR y ejecuta el job de Spark

```bash
ssh hadoop@$EMR_MASTER_IP "spark-submit etl-spark.py s3://'$emr_s3_name'/input/ s3://'$emr_s3_name'/output/spark"  
```
Cuando el job de Spark sea inicializado via línea de comando, logs serán mostrados en la consola.

6. Espera algunos minutos y navega a la consola de S3 para revisar la carpeta "output/spark" y ver los resultados

