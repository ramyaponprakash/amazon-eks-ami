## CICD guides

The repository is following Modularity and Reusability recommendations to have multiple pipelines for single repository.

Refs
* [SHIP-HATS runners](https://docs.developer.tech.gov.sg/docs/ship-hats-docs/tools/gitlab/runners)
* [SHIP-HATS templates](https://sgts.gitlab-dedicated.com/wog/gvt/ship/ship-hats-templates/-/blob/main/README.md)

## Directory Structure
``` bash
cicd/
|----- This README.md
|----- .gitlab-ci.yml # main pipeline for multiple downstream pipelines
|----- gitlab-ci/  # contains downstream pipeline configs
        |----- Image_Builder.yml # For EKS AMI builder jobs
        |----- Solace-EKS.yml # For Solace terraform (new module, TODO)
        |----- App-EKS-charts-publish.yml # For App EKS chart publish for all repos
        |----- App-EKS-charts-deploy.yml # For App EKS chart installation for cluster related charts
        |----- App-EKS-terraform.yml # For App EKS provision (old module)
        |----- ...
|----- templates/ # contains modular templates to extend from
        |----- .common.yml # common stuff
        |----- ...
```

## Runner selection

GitLab's `shared-runner`s generally fast enough, and scalable for multiple concurrent jobs.
But the shared runners may be run as `root` user but will not have enough privilege to access the host,
so `docker-in-docker` build won't work as expected. SHIP-HATS's GitLab is recommending to use [kaniko](https://github.com/GoogleContainerTools/kaniko) for better security practices.

The `shared-runner` is suitable for most cases.
The exceptions by SHIP-HATS team guide are [here](https://docs.developer.tech.gov.sg/docs/ship-hats-docs/tools/gitlab/runners?id=recommended-approach).
For creating own runners follow [this guide](https://docs.developer.tech.gov.sg/docs/ship-hats-docs/tools/gitlab/gitlab-runners)


## Kaniko build

The common handler of `.docker-image-build-and-push` performs kaniko build following the command.
It is something similar like `docker build ...`
```yaml
.docker-image-build-and-push:
  stage: build-push
  extends: .kaniko-builder
  script:
    - ( ... omitted ... )
    - >
      /kaniko/executor --context "$DOCKERFILE_CONTEXT" \
        --cache=true --cache-repo "$DOCKER_TARGET_REGISTRY/kaniko-caches" \
        --dockerfile "$DOCKERFILE_PATH/$DOCKERFILE_NAME" \
        --destination "$DOCKER_TARGET_REGISTRY/$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG" \
        --digest-file "$DIGESTFILE_NAME" $OPTS    
```

## F&Q

### - How to include(import) common jobs or templates into pipeline

Use `include:` in your repo's gitlab yaml file, 
```yaml
include:
  - project: "WOG/GVT/ADEX/ADEX/sense-eks-deployment"
    ref: "develop"
    file:
      - cicd/templates/.common.yml # aws, ssh, scp helpers
      - cicd/templates/.container.yml # kaniko, ecr helpers
      - cicd/templates/.helmfile.yml # helm, helmfile helpers
```

### - How to use common ssh/scp job

1. Use `include:` in your repo's gitlab yaml file,
```yaml
include:
  - project: "WOG/GVT/ADEX/ADEX/sense-eks-deployment"
    ref: "develop"
    file:
      - cicd/templates/.common.yml # aws, ssh, scp helpers
```

2. `extends` or `!reference` the common ssh, scp handler

ssh example over ssm send-command

more detail on [!reference tag](https://docs.gitlab.com/ee/ci/yaml/yaml_optimization.html#reference-tags)

```yaml
    script:
      - export INSTANCE_ID=EC2-INSTANCE-ID
      - export SSH_CMD="echo 'hello-world'"
      - !reference [.ssm-ssh-sh, script]
```

scp example over ssm start-session
```yaml
    script:
      - ' ... scripts to zip file ... '
      - export INSTANCE_ID=EC2-INSTANCE-ID
      - export EC2-USER=ubuntu
      - export SOURCE=./my-file.zip
      - export DEST=/home/ubuntu/
      - !reference [.ssm-ssh-sh, script]
```

### - How to execute command as `sudo` with ssm send-commend

```yaml
    - export SSH_CMD="sudo bash -c 'helm ... '"
    - !reference [.ssm-ssh-sh, script]
```


### - How to debug ssm send-commend execution logs

The `ssm send-command` execution result will be stored into CloudWatch log group `/aws/ssm/gitlab`

- GDS: [/aws/ssm/gitlab](https://ap-southeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#logsV2:log-groups/log-group/$252Faws$252Fssm$252Fgitlab)
- GCC: [/aws/ssm/gitlab](https://ap-southeast-1.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-1#logsV2:log-groups/log-group/$252Faws$252Fssm$252Fgitlab)

