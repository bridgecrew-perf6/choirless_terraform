# Choirless terraform

The terraform script is largely self-documenting, i.e. it builds what it says there!

## Some Notes

The API Gateway Deployment may need "tainting" to force it to be recreated when deploying new API endpoints:

```sh
terraform taint aws_api_gateway_deployment.choirless_api_deployment
terraform taint aws_api_gateway_usage_plan.choirlessUsagePlan
```

If you need to create S3 buckets you must remember to change the lambda role in iam.tf to give it access to the new bucket.

Some Lambdas have VPC and EFS config, others don't. See the pipeline Readme for an explanation of that.

Do not try to create the non-API lambdas using a foreach loop. We tried it and it did not work but we can't remember why!


