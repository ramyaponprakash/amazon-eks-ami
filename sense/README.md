## App EKS

---

### App EKS cluster upgrade guide

1. update variable `cluster_version` to desired eks version
2. update variable `kube_proxy_version`, `vpc_cni_version`, `coredns_version` by following AWS docs
   1. kube_proxy - https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
   2. CoreDNS - https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
   3. vpc_cni - https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
   4. (TBC) ebs add-on
3. (TBC) update node group AMI
   1. AMI change log - https://github.com/awslabs/amazon-eks-ami/blob/master/CHANGELOG.md
4. Run CI/CD to deploy changes

### Cluster charts

Details:
- [App-EKS-chart-deploy.yml](../cicd/README.md#app-eks-chart-deployyml)
- [App-EKS-chart-publish.yml](../cicd/README.md#app-eks-chart-publishyml)

### Getting started in local environment

#### Setup ENV vars
```shell
export HELM_BINARY=helm
export CLUSTER_NAME=test-name-here
export AWS_ACC=00000000
```

#### Generating testing template previews
```shell
helmfile -e dev -f ./sense/basecluster-common/helmfile.yaml template > preview.yaml 
```

#### Debugging composed variables
```shell
helmfile -e dev -f ./sense/basesense-backend/helmfile.yaml write-values
```

#### Testing terraform plan

```shell
terraform plan -var-file="./environment/dev/variables.tfvars" -target=module.eks_cluster
```