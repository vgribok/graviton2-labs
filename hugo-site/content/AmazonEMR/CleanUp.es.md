---
title: "Limpieza del laboratorio de EMR"
weight: 40
---

Para limpiar el laboratorio de EMR por favor ejecute el siguiente comando, el cual eliminará el clúster y los nodos que lo componen:

```bash
aws emr terminate-clusters --cluster-ids $EMR_CLUSTER_ID
```
Después de revisar el contenido en el bucket de S3 puedes elegir el borrar la salida del job o el bucket completo utilizando la consola web o la línea de comando.
