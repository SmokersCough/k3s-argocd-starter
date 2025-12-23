#!/bin/bash
# Script to label Kubernetes nodes for Longhorn automatic disk creation
# This enables Longhorn to automatically create default disks on labeled nodes

set -e

echo "Labeling nodes for Longhorn automatic disk creation..."

# Get all nodes
NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

if [ -z "$NODES" ]; then
    echo "No nodes found!"
    exit 1
fi

# Label each node
for node in $NODES; do
    echo "Labeling node: $node"
    kubectl label nodes "$node" node.longhorn.io/create-default-disk=true --overwrite
done

echo ""
echo "All nodes have been labeled with: node.longhorn.io/create-default-disk=true"
echo ""
echo "Verifying labels:"
kubectl get nodes --show-labels | grep -E "NAME|create-default-disk" || true
echo ""
echo "Longhorn will automatically create default disks on these nodes."
echo "Default disk path: /var/lib/longhorn"




