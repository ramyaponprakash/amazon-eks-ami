#!/bin/bash

CHART_NAME=$1
[[ -z "${CHART_NAME}" ]] && echo "CHART_NAME is required" && exit 1

LOC="/tmp/"
BUCKET="s3://sdx-eks-artifacts/charts/$CHART_NAME/"
BUCKET_NAME="sdx-eks-artifacts"
DEST_PATH="./tmp/chart/$CHART_NAME"

echo "publish $CHART_NAME to $BUCKET"

"${LOC}"aws s3api head-object --bucket "$BUCKET_NAME" --key "charts/$CHART_NAME/index.yaml" > /dev/null 2>&1 || INDEX_NOT_EXIST=true
if [ $INDEX_NOT_EXIST ]; then
  echo "init index.yaml in s3"
  "${LOC}"helm s3 init "$BUCKET"
else
  echo "index.yaml exist, skip helm s3 init"
fi

"${LOC}"helm repo add "$CHART_NAME" "$BUCKET"

echo "packaging $CHART_NAME"
"${LOC}"helm package ./sense/base/"$CHART_NAME"/ --destination "$DEST_PATH" || exit 1

for file in "$DEST_PATH"/*; do
  FILE_NAME=${file##*/}
  VERSION_EXT=${file##*-}
  VERSION=${VERSION_EXT%.*}
  echo "checking version $VERSION exist..."
  VERSION_RESULT=$(helm search repo "$CHART_NAME/$CHART_NAME" --version "$VERSION") # always exit 0
  if [ "$VERSION_RESULT" == "No results found" ]; then
     echo "publishing $FILE_NAME to s3 $CHART_NAME"
     "${LOC}"helm s3 push "$DEST_PATH/$FILE_NAME" "$CHART_NAME" --force || exit 1
  else
     echo "$VERSION exist in $CHART_NAME/$CHART_NAME, skip to push"
  fi
done

echo "publish $CHART_NAME - done!"
