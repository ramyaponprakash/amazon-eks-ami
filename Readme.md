# SENSE helm charts

## To setup EKS cluster

Bamboo: [sdx-eks-infra-deployment](https://bamboo.ship.gov.sg/browse/SEN-SDXEKSINFRA)

## To install cluster level charts and publish application charts

Bamboo CI: [sdx-eks-charts](https://bamboo.ship.gov.sg/browse/SEN-SENEKS)

Deployment: create release from the CI 

## Setup local testing of charts

### Setting required ENV
```shell
export HELM_BINARY=helm
export CLUSTER_NAME=test-name-here
export AWS_ACC=00000000
```

### Generating testing template previews
```shell
helmfile -e dev -f ./base/cluster-common/helmfile.yaml template > preview.yaml 
```

### Debugging composed variables
```shell
helmfile -e dev -f ./base/sense-backend/helmfile.yaml write-values
```

## To deploy application charts

Use application pipelines to create release after build.

## Test terraform plan in local

```shell
terraform plan -var-file="./environment/dev/variables.tfvars" -target=module.eks_cluster
```