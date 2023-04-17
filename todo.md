# TODO list

### Goal of Solace migration
1. Use provided material, NO reinventing the wheel
2. Focus on the entire setup, not minor configuration
3. Put greater effort where related to Solace Ops in a stable way
4. Use secured remote tf state so that code can be run in anywhere in convenience, optional pipeline (phase 2).


### Prerequisite
- [x] VPCs provisioning 
- [x] (decide) route table, nat, igw provisioning
- [x] (decide) subnets, subnet associations provisioning
- [x] (decide) initial bastion options

### Module
- Remote-state
  - [x] ~~(optional) S3~~ we will have manual s3 as confirmed
  - [ ] Code Dynamo table for global lock, need to check we can use s3 object lock as-is
- Network
  - [x] Test optional vpc creation
  - [x] [SENSE-5970](https://gdsjira.ship.gov.sg/browse/SENSE-5970) (optional) Code EIP conditional creation
  - [x] (manual ok) Need to add VPC peering (only possible for dev/qa)
  - [x] [SENSE-5994](https://gdsjira.ship.gov.sg/browse/SENSE-5994) Need VPC Endpoint?
    - [x] 1 VPC Endpoint per AZ (1 private subnet) 
    - [x] Secgroup for VPC Endpoints
  - [x] [SENSE-6007](https://gdsjira.ship.gov.sg/browse/SENSE-6007) Need to register Peer into route table
- Bastion
  - [x] Test optional creation
  - [ ] [SENSE-5987](https://gdsjira.ship.gov.sg/browse/SENSE-5987) Userdata for permanent HTTP_PROXY env vars
  - [ ] [SENSE-5993](https://gdsjira.ship.gov.sg/browse/SENSE-5993) Security group update to accept ssh from,
    - peered VPC CIDR
    - (need to discuss) bamboo whitelist access
- EKS
  - [x] Test with existing VPC
  - [x] Test with existing Bastion
  - [x] Code Enable secret encryption
  - [ ] Code add-ons
  - [ ] Code control-plane logging
  - [x] [SENSE-5963](https://gdsjira.ship.gov.sg/browse/SENSE-5963) Code node secgrp to include prefix and cidr
  - [x] [SENSE-5985](https://gdsjira.ship.gov.sg/browse/SENSE-5985) Code/Modify Custodian tag to ASG, ensure propagation, need rolling node?
  - [ ] (optional) Add post-fix for iam/policy creation
- EKS-Sol
  - [x] [SENSE-5985](https://gdsjira.ship.gov.sg/browse/SENSE-5985) Code/Modify Custodian tag to ASG, ensure propagation
- general
  - [x] decide what to `prevent_destroy` or other lifecycle
  - [x] adding Tag managed-by=Terraform as global tag

---
### CICD

- [ ] decided to use existing EKS CI but adding envs to CD - [SENSE-5955](https://gdsjira.ship.gov.sg/browse/SENSE-5955)
- [ ] Bamboo access
  - may need manual creation of pub bastion for init setups
- [ ] can we upload some files from Solace cloud console to S3?
  - pull image secret: gcr-reg-secret

---
### Dependencies

- Bamboo needs bastion to do terraform apply
  - [ ] can we use Bastion module?
- Sol-prod may allow to have public bastion
  - enough for init cluster
  - we will need private bastion (or alt deploy?)
- Sol-intra may need private bastion
  - [ ] prod bastion can access to new bastion in Sol-intra?
- [x] how we want to use Squid proxy?

----

### Documentation

- [ ] terraform doc for each module
- [ ] update Readme.md for repo explanation
- [ ] doc Solace installation steps
  - validation step requires to modify content
    - values.yaml -> update k8s.storageClass as 'gp3'
    - values.yaml -> update datacenter.verifyingSsl as false
    - values.yaml -> delete datacenter.httpsProxy
  - values.yaml may need to update its content per env
    - example
      - values.yaml -> update k8s.storageClass as 'gp3'
      - values.yaml -> update datacenter.verifyingSsl as false
      - values.yaml -> modify datacenter.httpsProxy
- [ ] link repo to Confluent


NOTE: module need to run within private subnet instance if we disable the public endpoint of EKS cluster.
