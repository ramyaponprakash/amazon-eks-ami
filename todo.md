# TODO list

### Goal of Solace migration
1. Use provided material, NO reinventing the wheel
2. Focus on the entire setup, not minor configuration
3. Put greater effort where related to Solace Ops in a stable way
4. Use secured remote tf state so that code can be run in anywhere in convenience, optional pipeline (phase 2).


### Prerequisite
- [x] VPCs provisioning 
- [ ] (decide) route table, nat, igw provisioning
- [ ] (decide) subnets, subnet assosications provisioning
- [ ] (decide) initial bastion options

### Module
- Remote-state
  - [ ] (optional) S3
  - [ ] Code Dynamo table for global lock
- Network
  - [ ] Test optional vpc creation
  - [ ] Review any missing parts
  - [ ] (optional) Code EIP conditional creation
  - [ ] Need to add VPC peering
- Bastion
  - [ ] Test optional creation
- EKS
  - [ ] Test with existing VPC
  - [ ] Test with existing Bastion
  - [ ] Code Enable secret encryption
  - [ ] Code add-ons
  - [ ] Code control-plane logging
  - [ ] Code node secgrp to include prefix and cidr
  - [ ] Code/Modify Custodian tag to ASG, ensure propagation, need rolling node?
- EKS-Sol
  - [ ] Code/Modify Custodian tag to ASG, ensure propagation
- general
  - [ ] decide what to `prevent_destroy`

---
### CICD

- [ ] Bamboo access
  - may need manual creation of pub bastion for init setups
- [ ] can we upload some files from Solace cloud console to S3?

#### Flow

CI 
- tf output, repo as artifact

CD
1. exec cicd/terraform-init.sh
2. may need init pub bastion for CD 
3. scp artifact to bastion 
4. ssh bastion (or turnel)
5. cd to env folder(by CD variable) -> terraform apply
6. (conditional) manual update CD variable to use module Bastion to replace No.2 

---
### Dependencies

- Bamboo needs bastion to do terraform apply
  - [ ] can we use Bastion module?
- Sol-prod may allow to have public bastion
  - enough for init cluster
  - we will need private bastion (or alt deploy?)
- Sol-intra may need private bastion
  - [ ] prod bastion can access to new bastion in Sol-intra?

----

### Documentation

- [ ] terraform doc for each module
- [ ] update Readme.md for repo explaination
- [ ] doc Solace installation steps
- [ ] link repo to Confluent



------------
remote-state
network
bastion
eks
eks-solace

-----------
remote-state
network
bastion
eks
eks-solace
eks-adex

---
remote-state
network
bastion
eks
eks-adex


----

1. git clone [repo]
2. git fetch
3. git checkout feature/solace