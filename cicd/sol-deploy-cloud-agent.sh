#!/bin/bash

MCA_VERSION=$1

if [[ -z $MCA_VERSION ]]; then
  MCA_VERSION="1.12.0"
fi

helm upgrade -install cloud-agent-rel https://cloud-agent-helm.s3.eu-north-1.amazonaws.com/solace-cloud-ca-$MCA_VERSION.tgz --namespace solace-cloud --values values.yaml