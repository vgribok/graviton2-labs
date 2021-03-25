---
title: "Graviton2 y Bases de Datos"
chapter: true
weight: 60
---

Graviton2 brinda mejoras costo-rendimiento en tus Bases de Datos Relacionales del servicio de Amazon RDS
comparado con las generaciones anteriores de tipos de instancia M5 y R5 con la utilizando de los nuevos procesadores AWS Graviton2 en RDS.

En esta seccion exploraremos el servicio de Amazon Relational Database Service (RDS) con el nuevo procesador Graviton2.
Aunque nos enfocaremos en bases de datos MySQL, este proceso es aplicable para otras motores de bases de datos (MySQL 8.0.17+, MariaDB 10.4.13+, y tambien a PostgreSQL 12.3+ son soportados para el uso de RDS con Gravtion2.
Cuando seleccionemos tipos de instancia para RDS podras elegir entre la familia de instancias M6g y R6g.

- Las instancias M6g son ideas para cargas de trabajo de propositos generales. 
- Las instancias R6g ofrecen 50% más memoria que las M6g y son ideales para cargas de trabajo que requieran de memoria intensiva, como por ejemplo, analiticos y big data.

Podras explorar los dos caminos existentes para migrar tus bases de datos de codigo abierto existentes a tipos de instancias con procesador Graviton2:

Opción 1) Crear una nueva base de datos con una versión compatible de motor de vases de datos a partir de un snapshot (recomendado para ambientes productivos)

Opción 2) Actualizar tu motor de bases de datos a una versión soportada por RDS con Graviton2, modificando el tipo de instancia de forma sencilla (ambientes de desarrollo/pruebas)
