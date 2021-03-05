#!/bin/bash

snapshot_uuid=`cat /dev/urandom | tr -dc 'a-z' | fold -w 16 | head -n 1`


aws ssm delete-parameter --name "graviton_rds_lab_snapshot"

echo "Saving snapshot id using AWS Systems Manager Parameter Store"

aws ssm put-parameter --name "graviton_rds_lab_snapshot" --value $snapshot_uuid  --type String  

echo "Creating RDS database snapshot"

aws rds create-db-snapshot --db-instance-identifier `aws cloudformation describe-stacks --stack-name GravitonID-rds-8 --query "Stacks[0].Outputs[1].OutputValue" --output text` --db-snapshot-identifier $snapshot_uuid >& /dev/null

echo -e "Your snapshop id : \e[1;32m $snapshot_uuid \e[0m"
