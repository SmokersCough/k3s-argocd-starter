# n8n Kubernetes Deployment

A production-ready n8n workflow automation platform deployment optimized for Kubernetes clusters with PostgreSQL database, Traefik ingress, and comprehensive monitoring.

## Overview

This project provides a complete n8n deployment for Kubernetes clusters with the following features:

- **Production Ready**: n8n 1.72.0 with PostgreSQL 15-alpine database
- **High Availability**: Persistent storage and health checks
- **Security Hardened**: Non-root containers, security contexts, and capability dropping
- **TLS Termination**: Automatic HTTPS with Let's Encrypt certificates
- **Automated Deployment**: One-command deployment with status monitoring
- **Resource Optimized**: Tailored for K3s environments with proper resource limits

## Project Structure

```
applications/n8n/
├── README.md                           # This comprehensive guide
├── deploy.sh                          # Automated deployment script
├── generate-secrets.sh                # Secure password generator
├── n8n-configmap.yaml                 # n8n configuration
├── n8n-deployment.yaml                # n8n application deployment
├── n8n-ingress-traefik.yaml           # Traefik ingress with TLS
├── n8n-pvc.yaml                       # n8n persistent storage (10Gi)
├── n8n-secrets.yaml                   # n8n secrets (passwords, encryption)
├── n8n-secrets-generated.yaml         # Generated secure secrets
├── n8n-service.yaml                   # n8n ClusterIP service
├── postgres-pvc.yaml                  # PostgreSQL persistent storage (5Gi)
├── postgres-secrets.yaml              # PostgreSQL secrets
├── postgres-secrets-generated.yaml    # Generated PostgreSQL secrets
├── postgres-service.yaml              # PostgreSQL headless service
├── postgres-statefulset.yaml          # PostgreSQL database
└── ingress.yaml                       # Additional ingress configuration
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Traefik       │    │   n8n           │
│   Ingress       │───►│   Application   │
│   (TLS)         │    │   (Port 5678)   │
└─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   PostgreSQL    │
                       │   Database      │
                       │   (Port 5432)   │
                       └─────────────────┘
                                │
                       ┌─────────────────┐
                       │   Longhorn      │
                       │   Storage       │
                       │   (15Gi total)  │
                       └─────────────────┘
```

## Prerequisites

- Kubernetes cluster (K3s recommended)
- Longhorn or compatible storage class
- Traefik ingress controller
- cert-manager for TLS certificates
- `kubectl` configured to access your cluster

## Quick Start

### 1. Deploy n8n

```bash
# Navigate to the n8n directory
cd applications/n8n

# Generate secure secrets (recommended for production)
./generate-secrets.sh

# Replace default secrets with generated ones
mv n8n-secrets-generated.yaml n8n-secrets.yaml
mv postgres-secrets-generated.yaml postgres-secrets.yaml

# Deploy everything
./deploy.sh
```

### 2. Configure DNS

Add to your `/etc/hosts` file (if using local domain):
```bash
echo "YOUR_K3S_NODE_IP n8n.katrelleslab.org" | sudo tee -a /etc/hosts
```

### 3. Access n8n

- **URL**: https://n8n.katrelleslab.org
- **Default Username**: `n8n`
- **Default Password**: `n8n` (change this in production!)

## Configuration

### Environment Variables

Key configuration options in `n8n-configmap.yaml`:

```yaml
# Environment
NODE_ENV: "production"
GENERIC_TIMEZONE: "Europe/Warsaw"

# URLs and Webhooks
WEBHOOK_URL: "https://n8n.katrelleslab.org/"
N8N_EDITOR_BASE_URL: "https://n8n.katrelleslab.org/"

# Database
DB_TYPE: "postgresdb"
DB_POSTGRESDB_HOST: "postgres-service"
DB_POSTGRESDB_PORT: "5432"

# Security
N8N_SECURE_COOKIE: "true"
N8N_DIAGNOSTICS_ENABLED: "false"

# Performance
EXECUTIONS_PROCESS: "main"
N8N_PAYLOAD_SIZE_MAX: "16"
```

### Resource Limits

- **n8n Application**:
  - CPU: 200m request, 800m limit
  - Memory: 512Mi request, 1Gi limit
- **PostgreSQL Database**:
  - CPU: 100m request, 500m limit
  - Memory: 256Mi request, 512Mi limit

### Storage

- **n8n Data**: 10Gi Longhorn volume at `/home/node/.n8n`
- **PostgreSQL**: 5Gi Longhorn volume at `/var/lib/postgresql/data`

## Security Features

### Container Security
- **Non-root containers**: Both n8n and PostgreSQL run as non-root users
- **Security contexts**: Capability dropping and read-only root filesystem
- **Network policies**: ClusterIP services for internal communication

### Secret Management
- **Automated generation**: `generate-secrets.sh` creates secure passwords
- **Encryption keys**: Unique encryption keys for each deployment
- **Database credentials**: Secure PostgreSQL authentication

### TLS Configuration
- **Let's Encrypt certificates**: Automatic HTTPS with cert-manager
- **Secure cookies**: Enabled for HTTPS environments
- **HSTS headers**: Configured via Traefik annotations

## Monitoring and Health Checks

### Health Probes
- **Startup probe**: Ensures n8n starts properly
- **Liveness probe**: Restarts container if n8n becomes unresponsive
- **Readiness probe**: Controls traffic routing during deployments

### Logging
- **Structured logging**: JSON format for better parsing
- **Log level**: Configurable (default: info)
- **Console output**: Optimized for Kubernetes environments

## Database Configuration

### PostgreSQL Setup
- **Version**: PostgreSQL 15-alpine
- **Storage**: 5Gi persistent volume
- **Backup**: Manual backup via kubectl exec
- **Performance**: Optimized for K3s environments

### Connection Settings
- **Host**: postgres-service (internal service)
- **Port**: 5432
- **Database**: n8n
- **Schema**: public

## Deployment Scripts

### deploy.sh
Automated deployment script that:
1. Creates the n8n namespace
2. Deploys persistent volumes
3. Applies secrets and configurations
4. Starts PostgreSQL StatefulSet
5. Waits for database readiness
6. Deploys n8n application
7. Configures ingress
8. Monitors deployment status

### generate-secrets.sh
Secure password generator that creates:
- n8n encryption keys
- PostgreSQL passwords
- Webhook secrets
- Database credentials

## Troubleshooting

### Common Issues

1. **Pod Not Starting**
   ```bash
   # Check pod status
   kubectl get pods -n n8n
   
   # Check pod logs
   kubectl logs -n n8n deployment/n8n
   kubectl logs -n n8n statefulset/postgres-statefulset
   ```

2. **Database Connection Issues**
   ```bash
   # Check PostgreSQL status
   kubectl get pods -n n8n -l app=postgres
   
   # Check database logs
   kubectl logs -n n8n statefulset/postgres-statefulset
   ```

3. **Ingress Issues**
   ```bash
   # Check ingress status
   kubectl get ingress -n n8n
   kubectl describe ingress n8n-ingress -n n8n
   ```

4. **Storage Issues**
   ```bash
   # Check persistent volumes
   kubectl get pvc -n n8n
   kubectl get pv
   ```

### Access Methods

1. **Direct Port Forward**
   ```bash
   kubectl port-forward -n n8n deployment/n8n 5678:5678
   # Access http://localhost:5678
   ```

2. **Database Access**
   ```bash
   kubectl exec -it -n n8n statefulset/postgres-statefulset -- psql -U n8n -d n8n
   ```

## Maintenance

### Updates
```bash
# Update n8n version
kubectl set image deployment/n8n n8n=n8nio/n8n:latest -n n8n

# Update PostgreSQL version
kubectl set image statefulset/postgres-statefulset postgres=postgres:16-alpine -n n8n
```

### Backups
```bash
# Backup n8n data
kubectl exec -n n8n deployment/n8n -- tar -czf /tmp/n8n-backup.tar.gz /home/node/.n8n

# Backup PostgreSQL
kubectl exec -n n8n statefulset/postgres-statefulset -- pg_dump -U n8n n8n > n8n-backup.sql
```

### Scaling
```bash
# Scale n8n (note: n8n doesn't support horizontal scaling by default)
kubectl scale deployment/n8n --replicas=1 -n n8n
```

## Customization

### Adding Custom Nodes
1. Access n8n web interface
2. Navigate to Settings > Community Nodes
3. Install custom nodes as needed

### Environment Variables
Edit `n8n-configmap.yaml` to add custom environment variables:
```yaml
data:
  CUSTOM_VARIABLE: "value"
```

### Webhook Configuration
Update webhook URLs in the ConfigMap:
```yaml
WEBHOOK_URL: "https://your-domain.com/"
N8N_EDITOR_BASE_URL: "https://your-domain.com/"
```

## Performance Optimization

### Resource Tuning
- Adjust CPU/memory limits based on workload
- Monitor resource usage with `kubectl top pods -n n8n`
- Scale resources as needed

### Database Optimization
- Monitor PostgreSQL performance
- Consider connection pooling for high-load scenarios
- Regular database maintenance and cleanup

### Storage Optimization
- Monitor disk usage with `kubectl exec` commands
- Implement backup strategies
- Consider storage class optimization

## Security Best Practices

1. **Change Default Passwords**: Always use `generate-secrets.sh` for production
2. **Network Policies**: Implement Kubernetes network policies
3. **Regular Updates**: Keep n8n and PostgreSQL updated
4. **Backup Strategy**: Implement regular backup procedures
5. **Access Control**: Use proper RBAC for Kubernetes access

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review n8n documentation
3. Check Kubernetes cluster logs
4. Verify network connectivity and DNS resolution

## License

This deployment configuration is provided as-is for educational and homelab use.# k3s-Applications
