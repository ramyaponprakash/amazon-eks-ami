#!/bin/bash

echo "[INFO] Disabling backend.tf"
mv "$1"/backend.tf "$1"/backend.tf.backup || { echo "Invalid path $SRC"; exit 1; }

echo "[INFO] Initialising local state for provisioning remote_state module"
terraform init -migrate-state -force-copy

echo "[INFO] Applying remote_state module...."
terraform apply -target module.remote_state --auto-approve

echo "[INFO] Enabling backend.tf"
mv "$1"/backend.tf.backup "$1"/backend.tf

echo "[INFO] Initialising remote_state"
terraform init -migrate-state -force-copy