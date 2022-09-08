## SENSE helm charts

### To setup EKS cluster

Bamboo: [sdx-eks-infra-deployment](https://bamboo.ship.gov.sg/browse/SEN-SDXEKSINFRA)

### To install cluster level charts and publish application charts

Bamboo: [sdx-eks-charts](https://bamboo.ship.gov.sg/browse/SEN-SENEKS)


### To deploy application charts

Use application pipelines to create release.

### Test terraform plan in local

terraform plan -var-file="./environment/dev/variables.tfvars" -target=module.eks_cluster