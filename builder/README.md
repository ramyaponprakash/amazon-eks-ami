### How it works

We are building AMI using AWS EKS official optimized AMI repository on the top of the CIS hardened image we subscribed.

- Official repo details: [Repo user guide](https://github.com/awslabs/amazon-eks-ami/blob/master/doc/USER_GUIDE.md)
- CIS Image: [Amazon Linux 2 CIS Level 1](https://aws.amazon.com/marketplace/pp/prodview-wv574yqgjv6jg?sr=0-4&ref_=beagle&applicationId=AWSMPContessa)

#### Support

- [Official Repo Issue](https://github.com/awslabs/amazon-eks-ami/issues)
- [CIS Support](https://www.cisecurity.org/support)

#### Linux distribution details

- [Amazon Linux 2 FAQs](https://aws.amazon.com/ko/amazon-linux-2/faqs/)
  - EOL: 2025-06-30
- [Amazon Linux 2 release notes](https://docs.aws.amazon.com/AL2/latest/relnotes/relnotes-al2.html)

### TODO

#### CICD
- [ ] Pin the AWS official repo tag in .gitmodules
- [x] echo and artifact  *manifest.json, *version-info.json
- [ ] Bamboo pipeline
- [ ] GitLab pipeline migration

#### Hardening
- [x] Amazon Linux CIS level 1 (done by subscribed image)
- [x] EKS CIS hardening (done by official repo)
- [ ] containerd CIS (The guide dose not exist yet. Docker CIS is not fully proper)