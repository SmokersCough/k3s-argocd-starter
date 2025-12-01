# Pi-hole Kubernetes Deployment

A comprehensive Kubernetes deployment for Pi-hole DNS server with high availability, monitoring, and synchronization capabilities.

## Overview

This project provides a complete Pi-hole deployment for Kubernetes clusters with the following features:

- **High Availability**: Primary and secondary Pi-hole instances with anti-affinity rules
- **DNS Synchronization**: Automated synchronization between Pi-hole instances using Nebula Sync
- **Monitoring**: Prometheus metrics collection and Grafana dashboard integration
- **Security**: TLS termination with Let's Encrypt certificates
- **Storage**: Persistent storage for Pi-hole configuration and data

## Project Structure

```
applications/pihole/
├── README.md                    # This comprehensive guide
├── kustomization.yaml          # Kustomize configuration
├── namespace.yaml              # Pi-hole namespace
├── secret.yaml                 # Pi-hole secrets
├── configmap.yaml              # Pi-hole configuration
├── pvc.yaml                    # Persistent volume claims
├── deployment.yaml             # Pi-hole deployments
├── service.yaml                # Pi-hole services
├── ingress.yaml                # Basic ingress (legacy)
├── primary-ingress.yaml        # Primary Pi-hole ingress
├── secondary-ingress.yaml      # Secondary Pi-hole ingress
├── admin-password              # Admin password file
└── admin-user                  # Admin username file
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Pi-hole       │    │   Pi-hole       │
│   Primary       │◄──►│   Secondary     │
│   (192.168.50.81)│    │   (192.168.50.82)│
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────┬───────────┘
                     │
            ┌─────────────────┐
            │   Nebula Sync   │
            │   (Scheduler)   │
            └─────────────────┘
                     │
            ┌─────────────────┐
            │   Prometheus    │
            │   + Grafana     │
            └─────────────────┘
```

## Prerequisites

- Kubernetes cluster (K3s recommended)
- Longhorn or compatible storage class
- Traefik ingress controller
- kube-prometheus-stack for monitoring
- kube-vip for LoadBalancer IP management
- cert-manager for TLS certificates

## Components

### Core Services
- **Pi-hole Primary**: Main DNS server instance
- **Pi-hole Secondary**: Backup DNS server instance
- **Nebula Sync**: Automated synchronization between instances

### Monitoring
- **Pi-hole Exporter**: Prometheus metrics collection
- **ServiceMonitor**: Automatic metrics discovery
- **Grafana Dashboard**: Visualization of Pi-hole statistics

### Networking
- **LoadBalancer Services**: External DNS access
- **Ingress Resources**: Web interface access with TLS
- **Anti-affinity Rules**: Ensures instances run on different nodes

## Quick Start

### 1. Deploy Pi-hole

```bash
# Apply the complete deployment
kubectl apply -k .

# Or apply individual components
kubectl apply -f namespace.yaml
kubectl apply -f .
```

### 2. Configure DNS

Update your network's DNS settings to use the LoadBalancer IPs:
- Primary DNS: `192.168.50.81`
- Secondary DNS: `192.168.50.82`

### 3. Access Web Interface

- Primary: https://pihole.katrelleslab.org
- Secondary: https://pihole2.katrelleslab.org

## Configuration

### Environment Variables

Key configuration options in `configmap.yaml`:

```yaml
TZ: "America/New_York"                    # Timezone
DNSSEC: "true"                           # Enable DNSSEC
DNS_BOGUS_PRIV: "true"                   # Block private IP ranges
DNSMASQ_LISTENING: "all"                 # Listen on all interfaces
FTLCONF_dns_listeningMode: "all"         # Pi-hole v6 listening mode
FTLCONF_dns_localService: "false"        # Allow non-local connections
```

### IP Addresses

Update the following IP addresses in `configmap.yaml`:
- `ServerIP`: Primary Pi-hole IP (192.168.50.81)
- Secondary `ServerIP`: Secondary Pi-hole IP (192.168.50.82)

### Domains

Update domain names in ingress files:
- `primary-ingress.yaml`: pihole.katrelleslab.org
- `secondary-ingress.yaml`: pihole2.katrelleslab.org

## Synchronization

The deployment includes Nebula Sync for automated synchronization:

### Sync Configuration
- **Full Sync**: Disabled (incremental sync only)
- **Gravity Sync**: Enabled (ad lists, domain lists)
- **Config Sync**: DNS settings only
- **Schedule**: Daily at midnight

### Sync Settings
```yaml
FULL_SYNC: "false"                       # Incremental sync
RUN_GRAVITY: "true"                      # Sync gravity database
CRON: "0 0 * * *"                        # Daily at midnight
SYNC_GRAVITY_AD_LIST: "true"             # Sync ad lists
SYNC_GRAVITY_DOMAIN_LIST: "true"         # Sync domain lists
```

## Monitoring

### Metrics Collection
- Pi-hole metrics exposed on port 9617
- Prometheus ServiceMonitor for automatic discovery
- Grafana dashboard for visualization

### Key Metrics
- DNS queries per second
- Blocked queries percentage
- Top blocked domains
- Client activity

## Security

### TLS Configuration
- Let's Encrypt certificates via cert-manager
- HSTS headers enabled
- Security headers configured

### Access Control
- No web password by default (configurable)
- Network-based access control
- DNS service isolation

## Storage

### Persistent Volumes
- Primary Pi-hole: 1Gi storage
- Secondary Pi-hole: 1Gi storage
- Longhorn storage class recommended

### Data Persistence
- Pi-hole configuration
- Gravity database
- Custom DNS settings
- Query logs

## Troubleshooting

### Common Issues

1. **DNS Not Resolving**
   ```bash
   # Check service status
   kubectl get svc -n pihole
   
   # Check pod logs
   kubectl logs -n pihole deployment/pihole-primary
   ```

2. **Synchronization Issues**
   ```bash
   # Check Nebula Sync logs
   kubectl logs -n pihole deployment/nebula-sync
   ```

3. **Certificate Issues**
   ```bash
   # Check certificate status
   kubectl get certificates -n pihole
   ```

### Logs
```bash
# Pi-hole primary logs
kubectl logs -n pihole deployment/pihole-primary -c pihole

# Pi-hole secondary logs
kubectl logs -n pihole deployment/pihole-secondary -c pihole

# Nebula Sync logs
kubectl logs -n pihole deployment/nebula-sync

# Metrics exporter logs
kubectl logs -n pihole deployment/pihole-primary -c pihole-exporter
```

## Maintenance

### Updates
```bash
# Update Pi-hole image
kubectl set image deployment/pihole-primary pihole=pihole/pihole:latest -n pihole
kubectl set image deployment/pihole-secondary pihole=pihole/pihole:latest -n pihole
```

### Backup
```bash
# Backup Pi-hole configuration
kubectl exec -n pihole deployment/pihole-primary -c pihole -- pihole -a -t
```

## Customization

### Adding Custom Block Lists
1. Access Pi-hole web interface
2. Navigate to Adlists
3. Add custom block list URLs
4. Update gravity database

### Custom DNS Records
1. Edit `pihole-dnsmasq-config` ConfigMap
2. Add custom DNS records
3. Restart Pi-hole pods

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Pi-hole documentation
3. Check Kubernetes cluster logs
4. Verify network connectivity

## License

This deployment configuration is provided as-is for educational and homelab use.
