#!/bin/bash

TARGET=/Users/alexmin/work/sense-eks-deployment
PEMFILE=~/.ssh/sdx-qa.pem
USER=ubuntu
IP=3.1.217.206
DEST_LOC=/home/ubuntu/tmp
DEST_NAME=repo

cd $TARGET && rm $DEST_NAME.zip
zip -r $DEST_NAME.zip . -x "*.terraform*/*" "*.git*/*" "*.idea*/*"

ssh -oStrictHostKeyChecking=no -i $PEMFILE -o ConnectTimeout=5 -t "$USER@${IP}" "rm $DEST_LOC/$DEST_NAME.zip; rm -rf $DEST_LOC/$DEST_NAME"
scp -i ~/.ssh/sdx-qa.pem ./$DEST_NAME.zip $USER@3.1.217.206:$DEST_LOC/
ssh -oStrictHostKeyChecking=no -i $PEMFILE -o ConnectTimeout=5 -t "$USER@${IP}" "mkdir $DEST_LOC/$DEST_NAME; unzip $DEST_LOC/$DEST_NAME.zip -d $DEST_LOC/$DEST_NAME"