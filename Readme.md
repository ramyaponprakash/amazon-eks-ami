# SENSE helm charts

## Setup EKS cluster for new environment

Define new env variables under `/terraform/environment`.

Bamboo CI: [sdx-eks-infra-deployment](https://bamboo.ship.gov.sg/browse/SEN-SDXEKSINFRA)

Create release from CI build result, proceed CD.

Bamboo CD: [sdx-eks-infra-deployment](https://bamboo.ship.gov.sg/deploy/viewDeploymentProjectEnvironments.action?id=71761929)

## Cluster upgrade guide

1. update variable `cluster_version` to desired eks version
2. update variable `kube_proxy_version`, `vpc_cni_version`, `coredns_version` by following AWS docs
   1. kube_proxy - https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
   2. CoreDNS - https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
   3. vpc_cni - https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
   4. (TBC) ebs add-on
3. (TBC) update node group AMI
4. Run CI/CD to deploy changes

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

## Deploying application charts

Use application pipelines to create release after build.

charts will be stored in [s3 bucket](https://s3.console.aws.amazon.com/s3/buckets/sdx-eks-artifacts?region=ap-southeast-1&tab=objects)

## Testing terraform plan in local

```shell
terraform plan -var-file="./environment/dev/variables.tfvars" -target=module.eks_cluster
```