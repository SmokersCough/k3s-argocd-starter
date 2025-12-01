#!/bin/bash

set -e

echo "🚀 Deploying n8n to Kubernetes with optimizations..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

print_status "Connected to Kubernetes cluster"

# Create namespace if it doesn't exist
print_status "Creating namespace 'n8n'..."
kubectl create namespace n8n --dry-run=client -o yaml | kubectl apply -f -

# Deploy in order
print_status "Deploying PostgreSQL PVC..."
kubectl apply -f postgres-pvc.yaml

print_status "Deploying n8n PVC..."
kubectl apply -f n8n-pvc.yaml

print_status "Deploying secrets..."
kubectl apply -f postgres-secrets.yaml
kubectl apply -f n8n-secrets.yaml

print_status "Deploying ConfigMap..."
kubectl apply -f n8n-configmap.yaml

print_status "Deploying PostgreSQL StatefulSet..."
kubectl apply -f postgres-statefulset.yaml

print_status "Deploying PostgreSQL Service..."
kubectl apply -f postgres-service.yaml

print_status "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n n8n --timeout=300s

print_status "Deploying n8n application..."
kubectl apply -f n8n-deployment.yaml

print_status "Deploying n8n Service..."
kubectl apply -f n8n-service.yaml

print_status "Deploying Traefik Ingress..."
kubectl apply -f n8n-ingress-traefik.yaml

print_status "Waiting for n8n to be ready..."
kubectl wait --for=condition=ready pod -l app=n8n -n n8n --timeout=300s

print_success "Deployment completed successfully!"

echo ""
echo "📋 Deployment Summary:"
echo "======================"
echo "• Namespace: n8n"
echo "• PostgreSQL: postgres:15-alpine with persistent storage (5Gi)"
echo "• n8n: n8nio/n8n:1.72.0 with persistent storage (10Gi)"
echo "• Ingress: Traefik with TLS termination"
echo "• URL: https://n8n.katrelleslab.org"
echo ""

# Get pod status
print_status "Current pod status:"
kubectl get pods -n n8n

echo ""
print_status "Service status:"
kubectl get svc -n n8n

echo ""
print_status "Ingress status:"
kubectl get ingress -n n8n

echo ""
print_warning "Remember to:"
echo "1. Ensure DNS resolution for 'n8n.katrelleslab.org' points to your cluster"
echo "2. Generate secure secrets using ./generate-secrets.sh for production use"
echo "3. Check the logs if pods are not running: kubectl logs -n n8n <pod-name>"

print_success "n8n is now available at https://n8n.katrelleslab.org"
