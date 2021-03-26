This project design to help you deploy services such as EKS, ECS, RDS, and EMR 
on Graviton2 instances.
All the labs use AWS CDK for initial deployment and utiliza dedicated VPC.

Currently covered scenarios include :

* EKS cluster with multi-architecture (x86-64 and arm64) nodegroups
* ECS cluster with sample task and service running on Graviton2 instance type
* CI pipeline for multi-architecture docker container images using CodePipeline, CodeBuild, CodeCommit, and ECR (with docker manifests)
* CI pipeline for running .Net Core 5 on Amazon EKS cluster 
* RDS migration scenario from MySQl 8 on m5 instance type to MySQL on m6g instance type
* RDS migration scenario from MySQl 5 on m5 instance type ->  in-place major version upgrade  MySQL 8 ->  to in-place instance change to m6g instance type
* EMR cluster with sample ETL Spark job` running on Graviton2 instance type

To launch Workshop in Cloud9 environment install Hugo from Fedora project:

```
sudo wget https://copr.fedorainfracloud.org/coprs/daftaupe/hugo/repo/epel-7/daftaupe-hugo-epel-7.repo -O /etc/yum.repos.d/hugo.repo
sudo yum update
sudo yum install hugo
```

For more information, and instructions for other operating systems please visit : https://gohugo.io/getting-started/installing/

Once Hugo is installed you can start Hugo server using following commands : 

```
cd graviton2-labs/hugo-site/workshop
hugo -v server
```

This will start Hugo server on your Cloud9 instance. PLease note by default Hugo listens on por 1313 and binds to Cloud9 localhost ip and is accessible via "http://localhost:1313/" URL.

To bind specific IP and expose hugo to external access use "--bind" option as follows.

```
hugo -v server --bind <primary eth ip>
```
