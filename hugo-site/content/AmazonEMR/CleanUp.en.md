---
title: "EMR Cleanup"
weight: 40
---

To cleanup the EMR cluster please execute following command : 

```bash
aws emr terminate-clusters --cluster-ids $EMR_CLUSTER_ID
```
After reviewing the contents of S3 bucket you can elect to empty and delete job outputs via AWS S3 console or using CLI.
