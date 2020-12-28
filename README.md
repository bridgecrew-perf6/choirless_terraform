# Choirless terraform

## Notes

The API Gateway Deployment may need "tainting" to force it to be recreated when deploying new API endpoints:

```sh
terraform taint aws_api_gateway_deployment.choirless_api_deployment
```


