---
title: "Graviton2 and databases"
chapter: true
weight: 60
---

Graviton2 brings better cost-performance for your Amazon Relational Database Service (RDS) databases, 
compared to the previous M5 and R5 generation of database instance types, with the availability of AWS Graviton2 processors for RDS. 


In this Section, we will explore running Amazon Relational Database Service (RDS) with Graviton2 instance types.
We will focus on MySQL database backend, however the outlined processed are applicable to other database engines database engines (MySQL 8.0.17 and higher, MariaDB 10.4.13 and higher, 
and PostgreSQL 12.3 and higher) supported by RDS for Gravtion2. 
When selecting Graviton2 instance types for RDS and you can choose between M6g and R6g instance families.

M6g instances are ideal for general purpose workloads. R6g instances offer 50% more memory than their M6g counterparts and are 
ideal for memory intensive workloads, such as Big Data analytics.


You can explore one of two paths for moving your exisint open source database backend to Graviton2 instance types: 

Option 1) Creating a new database from compatible databse version snapshot (recommended for production process)

Option 2) Upgrading your older database to a version supported by RDS with Graviton2, and modyfying instance type (test/dev environment)





