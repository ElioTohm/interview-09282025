#!/bin/bash

# This script creates a KinD cluster using a specified configuration file.

CONFIG_FILE="$HOME/.dotfiles/scripts/kind/kind_config.yaml"
CLUSTER_NAME="local"
REG_NAME='kind-registry'
REG_PORT='5000'

echo "Checking for KinD and kubectl..."
if ! command -v kind &>/dev/null || ! command -v kubectl &>/dev/null; then
  echo "KinD or kubectl could not be found. Please install them first."
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Configuration file '$CONFIG_FILE' not found."
  exit 1
fi

# 1. Start the registry container (if not already running)
echo "Starting local registry container..."
if [ "$(docker inspect -f '{{.State.Running}}' "${REG_NAME}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${REG_PORT}:5000" --name "${REG_NAME}" \
    registry:3
fi

# 2. Create the KinD cluster
echo "Creating KinD cluster '$CLUSTER_NAME'..."
kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG_FILE"

# 3. Connect the registry to the cluster's network
# This must be done AFTER the cluster is created.
echo "Connecting registry to the 'kind' network..."
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${REG_NAME}")" = 'null' ]; then
  docker network connect "kind" "${REG_NAME}"
fi

# --- Post-creation steps ---

if [ $? -eq 0 ]; then
  echo "----------------------------------------"
  echo "✅ Successfully created KinD cluster '$CLUSTER_NAME'."

  echo "Applying registry ConfigMap and Ingress controller..."

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REG_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
  echo "Waiting for Ingress controller to be ready..."
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

  echo "🚀 Cluster is ready!"
  echo "----------------------------------------"
else
  echo "----------------------------------------"
  echo "❌ Error: Failed to create KinD cluster '$CLUSTER_NAME'."
  echo "----------------------------------------"
fi

echo KUBE_CONFIG=\" >.secrets
kubectl config view --raw >>.secrets
echo "\"" >>.secrets
