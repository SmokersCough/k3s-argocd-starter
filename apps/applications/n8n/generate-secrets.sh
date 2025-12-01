#!/bin/bash

# Script to generate secure random passwords for n8n deployment
# Run this script to generate new secrets before deployment

echo "🔐 Generating secure secrets for n8n deployment..."

# Generate random passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)

echo "✅ Generated secure secrets"

# Create n8n secrets file
cat > n8n-secrets-generated.yaml << EOF
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: n8n-secrets
  namespace: n8n
  labels:
    app: n8n
    component: secrets
stringData:
  # Database password
  DB_POSTGRESDB_PASSWORD: "${POSTGRES_PASSWORD}"
  # Encryption key to hash all data
  N8N_ENCRYPTION_KEY: "${N8N_ENCRYPTION_KEY}"
EOF

# Create postgres secrets file
cat > postgres-secrets-generated.yaml << EOF
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: postgres-secrets
  namespace: n8n
  labels:
    app: postgres
    component: secrets
stringData:
  PGDATA: "/var/lib/postgresql/data/pgdata"
  POSTGRES_USER: "n8n"
  POSTGRES_DB: "n8n"
  POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
EOF

echo "📝 Generated secret files:"
echo "   - n8n-secrets-generated.yaml"
echo "   - postgres-secrets-generated.yaml"
echo ""
echo "🔑 n8n Authentication:"
echo "   ✅ Basic Auth DISABLED - You'll create admin account on first visit"
echo "   🌐 Visit https://n8n.local to set up your admin user"
echo ""
echo "⚠️  IMPORTANT: Save the encryption key securely!"
echo "⚠️  Replace the existing secret files with the generated ones before deployment"
echo ""
echo "To apply the new secrets:"
echo "   kubectl apply -f n8n-secrets-generated.yaml"
echo "   kubectl apply -f postgres-secrets-generated.yaml"
