# Home Assistant Kubernetes Deployment

A production-ready Home Assistant deployment optimized for Kubernetes clusters with persistent storage and Traefik ingress.

## Overview

This deployment provides a complete Home Assistant setup for Kubernetes clusters with the following features:

- **Production Ready**: Home Assistant latest with persistent storage
- **High Availability**: Persistent storage for configuration and data
- **Security Hardened**: Non-root containers and security contexts
- **TLS Termination**: Automatic HTTPS with Let's Encrypt certificates
- **Resource Optimized**: Tailored for K3s environments with proper resource limits

## Architecture

```
┌─────────────────┐
│   Traefik       │
│   Ingress       │───► Home Assistant
│   (TLS)         │     (Port 8123)
└─────────────────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │   Longhorn      │
                 │   Storage       │
                 │   (20Gi)        │
                 └─────────────────┘
```

## Prerequisites

- Kubernetes cluster (K3s recommended)
- Longhorn or compatible storage class
- Traefik ingress controller
- cert-manager for TLS certificates
- `kubectl` configured to access your cluster

## Quick Start

### 1. Deploy Home Assistant

The deployment will be automatically managed by ArgoCD. Once synced, Home Assistant will be available at:

- **URL**: https://homeassistant.katrelleslab.org

### 2. Initial Setup

1. Access Home Assistant via the ingress URL
2. Complete the initial setup wizard
3. Configure your integrations and devices

## Configuration

### Resource Limits

- **CPU**: 200m request, 2000m limit
- **Memory**: 512Mi request, 2Gi limit

### Storage

- **Home Assistant Data**: 20Gi Longhorn volume at `/config`
- Stores configuration, database, and add-ons

### Environment Variables

Key configuration options:

- `TZ`: Timezone (default: America/New_York)

## Security Features

### Container Security
- **Non-root containers**: Home Assistant runs as user 1000
- **Security contexts**: Capability dropping with minimal required capabilities
- **Network policies**: ClusterIP service for internal communication

### TLS Configuration
- **Let's Encrypt certificates**: Automatic HTTPS with cert-manager
- **Secure headers**: Configured via Traefik annotations

## Monitoring and Health Checks

### Health Probes
- **Startup probe**: Ensures Home Assistant starts properly (30s initial delay)
- **Liveness probe**: Restarts container if Home Assistant becomes unresponsive
- **Readiness probe**: Controls traffic routing during deployments

## Troubleshooting

### Common Issues

1. **Pod Not Starting**
   ```bash
   # Check pod status
   kubectl get pods -n home-assistant
   
   # Check pod logs
   kubectl logs -n home-assistant deployment/home-assistant
   ```

2. **Ingress Issues**
   ```bash
   # Check ingress status
   kubectl get ingress -n home-assistant
   kubectl describe ingress home-assistant -n home-assistant
   ```

3. **Storage Issues**
   ```bash
   # Check persistent volumes
   kubectl get pvc -n home-assistant
   kubectl get pv
   ```

### Access Methods

1. **Direct Port Forward**
   ```bash
   kubectl port-forward -n home-assistant deployment/home-assistant 8123:8123
   # Access http://localhost:8123
   ```

## Maintenance

### Updates
```bash
# Update Home Assistant version
kubectl set image deployment/home-assistant home-assistant=homeassistant/home-assistant:latest -n home-assistant
```

### Backups
```bash
# Backup Home Assistant data
kubectl exec -n home-assistant deployment/home-assistant -- tar -czf /tmp/ha-backup.tar.gz /config
kubectl cp home-assistant/<pod-name>:/tmp/ha-backup.tar.gz ./ha-backup.tar.gz
```

## Network Discovery

Home Assistant may need additional network configuration for device discovery:

- **mDNS/Bonjour**: May require hostNetwork or additional network policies
- **UPnP**: Works through ClusterIP service
- **Zigbee/Z-Wave**: May require USB passthrough or network bridges

For advanced networking needs, consider:
- Using hostNetwork mode (requires security considerations)
- Deploying a separate mDNS reflector service
- Using network policies to allow discovery traffic

## Customization

### Environment Variables
Edit `deployment.yaml` to add custom environment variables:
```yaml
env:
- name: CUSTOM_VARIABLE
  value: "value"
```

### Resource Limits
Adjust CPU/memory limits in `deployment.yaml` based on your workload:
```yaml
resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 2000m
    memory: 2Gi
```

## Security Best Practices

1. **Change Default Passwords**: Set strong passwords in Home Assistant
2. **Network Policies**: Implement Kubernetes network policies if needed
3. **Regular Updates**: Keep Home Assistant updated
4. **Backup Strategy**: Implement regular backup procedures
5. **Access Control**: Use proper RBAC for Kubernetes access

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Home Assistant documentation
3. Check Kubernetes cluster logs
4. Verify network connectivity and DNS resolution
