# 🏠 Homepage Dashboard

A beautiful, customizable dashboard for accessing and monitoring all your homelab services in one central location.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Service Integration](#service-integration)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)

## 🎯 Overview

Homepage Dashboard provides a centralized, beautiful interface for accessing all your homelab services including n8n, Pi-hole, Uptime Kuma, ArgoCD, and more. It features a modern, responsive design with real-time service status indicators and customizable widgets.

## ✨ Features

### 🎨 Beautiful Interface
- **Modern Design**: Clean, responsive layout that works on all devices
- **Dark/Light Themes**: Customizable appearance to match your preferences
- **Mobile Responsive**: Perfect experience on phones, tablets, and desktops
- **Custom Icons**: Beautiful icons for each service

### 📊 Service Management
- **Service Cards**: Quick access to all homelab services
- **Status Indicators**: Real-time up/down status for each service
- **Grouped Layout**: Organize services by category (DNS, Automation, etc.)
- **Click-to-Access**: Direct links to service interfaces

### 🔧 Widgets & Customization
- **System Stats**: CPU, memory, disk usage monitoring
- **Weather Widget**: Current conditions and forecast
- **Search**: Quick service discovery
- **Bookmarks**: External resource links
- **Customizable Layout**: Drag and drop service arrangement

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                Homepage Dashboard Architecture          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌────────────────────────────────────────────────┐     │
│  │         Web Interface (Port 3000)              │     │
│  │  - Service Cards                               │     │
│  │  - Widgets                                     │     │
│  │  - Search & Navigation                         │     │
│  └────────────────────────────────────────────────┘     │
│              ↓                    ↓                      │
│  ┌─────────────────┐   ┌──────────────────────┐        │
│  │  Configuration  │   │  Service Integration │        │
│  │  - config.json  │   │  - API Status Checks │        │
│  │  - services.yaml│   │  - Real-time Updates │        │
│  │  - widgets.yaml │   │  - Status Indicators │        │
│  │  - bookmarks.yaml│  └──────────────────────┘        │
│  └─────────────────┘              ↓                     │
│         ↓                          ↓                     │
│  ┌──────────────────────────────────────────────┐       │
│  │      ConfigMaps (Configuration Storage)      │       │
│  │      - Read-only configuration files         │       │
│  │      - Service definitions                   │       │
│  │      - Widget settings                       │       │
│  └──────────────────────────────────────────────┘       │
│                                                         │
│  External Access via Traefik Ingress:                   │
│  https://homepage.katrelleslab.org                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ↓    ↓    ↓    ↓    ↓    ↓    ↓    ↓
    ┌────┴────┴────┴────┴────┴────┴────┴────────┐
    │         Monitored Services                 │
    ├────────────────────────────────────────────┤
    │ • n8n.katrelleslab.org                     │
    │ • pihole-primary.katrelleslab.org          │
    │ • pihole-secondary.katrelleslab.org        │
    │ • uptime.katrelleslab.org                  │
    │ • argocd.katrelleslab.org                  │
    │ • grafana.katrelleslab.org                 │
    │ • Custom Services...                       │
    └────────────────────────────────────────────┘
```

## 📦 Prerequisites

Before deploying Homepage Dashboard, ensure you have:

- ✅ **K3s Cluster**: Running K3s cluster with at least 1 node
- ✅ **Traefik Ingress**: Configured ingress controller
- ✅ **Cert-Manager**: For automatic TLS certificate management
- ✅ **DNS Configuration**: `homepage.katrelleslab.org` pointing to your cluster

### Resource Requirements

- **CPU**: 100m request, 500m limit
- **Memory**: 128Mi request, 512Mi limit
- **Storage**: Configuration stored in ConfigMaps (no persistent storage needed)

## 🚀 Quick Start

### 1. Clone or Navigate to Directory

```bash
cd /home/trelle/k3s/applications/homepage
```

### 2. Deploy to Kubernetes

```bash
# Deploy using Kustomize
kubectl apply -k .

# Or deploy individually
kubectl apply -f namespace.yaml
kubectl apply -f configmap-config.yaml
kubectl apply -f configmap-services.yaml
kubectl apply -f configmap-widgets.yaml
kubectl apply -f configmap-bookmarks.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

### 3. Verify Deployment

```bash
# Check pod status
kubectl get pods -n homepage

# Check logs
kubectl logs -n homepage -l app=homepage

# Check ingress
kubectl get ingress -n homepage
```

### 4. Access Homepage Dashboard

Navigate to: **https://homepage.katrelleslab.org**

## ⚙️ Configuration

### Main Configuration (`configmap-config.yaml`)

Controls the overall appearance and behavior:

```yaml
data:
  config.json: |
    {
      "title": "Homelab Dashboard",
      "theme": "dark",
      "timezone": "America/New_York",
      "primaryColor": "#3b82f6",
      "accentColor": "#10b981"
    }
```

### Service Configuration (`configmap-services.yaml`)

Define all your homelab services:

```yaml
data:
  services.yaml: |
    - Automation & Workflows:
        - n8n:
            href: https://n8n.katrelleslab.org
            icon: n8n.png
            description: Workflow Automation
        - Uptime Kuma:
            href: https://uptime.katrelleslab.org
            icon: uptime-kuma.png
            description: Service Monitoring
```

### Widget Configuration (`configmap-widgets.yaml`)

Configure system widgets:

```yaml
data:
  widgets.yaml: |
    - System Resources:
        - System Stats:
            type: system-stats
            config:
              cpu: true
              memory: true
              disk: true
```

### Bookmarks Configuration (`configmap-bookmarks.yaml`)

Add external resource links:

```yaml
data:
  bookmarks.yaml: |
    - External Resources:
        - GitHub:
            href: https://github.com/SmokersCough/k3s
            icon: github.png
            description: Homelab Repository
```

## 🔗 Service Integration

### Currently Integrated Services

1. **n8n** - Workflow automation platform
2. **Pi-hole Primary & Secondary** - DNS ad blocking
3. **Uptime Kuma** - Service monitoring
4. **ArgoCD** - GitOps continuous deployment
5. **RetroArch** - Multi-platform emulator

### Adding New Services

To add a new service, edit `configmap-services.yaml`:

```yaml
- New Category:
    - Service Name:
        href: https://service.katrelleslab.org
        icon: service.png
        description: Service Description
        widget:
          type: service-type
          url: https://service.katrelleslab.org
          key: service-key
```

### API Integration

For services that support API integration:

```yaml
- Service Name:
    href: https://service.katrelleslab.org
    icon: service.png
    description: Service Description
    widget:
      type: service-api
      url: https://service.katrelleslab.org/api
      key: api-key
      headers:
        Authorization: "Bearer your-token"
```

## 🎨 Customization

### Themes

Available themes:
- `dark` - Dark mode (default)
- `light` - Light mode
- `auto` - Follow system preference

### Colors

Customize the color scheme in `configmap-config.yaml`:

```json
{
  "primaryColor": "#3b82f6",
  "secondaryColor": "#6b7280",
  "accentColor": "#10b981",
  "dangerColor": "#ef4444",
  "warningColor": "#f59e0b"
}
```

### Layout

Services are organized by categories:
- **Automation & Workflows** - n8n, Uptime Kuma
- **DNS & Network** - Pi-hole instances
- **GitOps & Deployment** - ArgoCD
- **Gaming & Entertainment** - RetroArch

### Icons

Icons are automatically loaded from the Homepage icon library. Available icons include:
- `n8n.png`, `pihole.png`, `uptime-kuma.png`
- `argocd.png`, `retroarch.png`, `github.png`
- `kubernetes.png`, `cloudflare.png`

## 🔧 Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl get pods -n homepage

# Check pod events
kubectl describe pod -n homepage -l app=homepage

# Check logs
kubectl logs -n homepage -l app=homepage
```

### Common Issues

#### Issue: Pod in CrashLoopBackOff

**Cause**: Configuration or permission issues

**Solution**:
```bash
# Check logs for specific error
kubectl logs -n homepage -l app=homepage --previous

# Verify ConfigMaps exist
kubectl get configmaps -n homepage

# Check if config directory is writable
kubectl exec -n homepage $(kubectl get pod -n homepage -l app=homepage -o jsonpath='{.items[0].metadata.name}') -- ls -la /app/config
```

#### Issue: Cannot Access Web Interface

**Cause**: Ingress or service misconfiguration

**Solution**:
```bash
# Check ingress
kubectl get ingress -n homepage

# Check service
kubectl get svc -n homepage

# Test service directly
kubectl port-forward -n homepage svc/homepage 3000:3000
# Access at http://localhost:3000
```

#### Issue: Services Not Loading

**Cause**: Configuration file format issues

**Solution**:
```bash
# Validate YAML syntax
kubectl get configmap homepage-services -n homepage -o yaml

# Check if services are properly formatted
kubectl exec -n homepage $(kubectl get pod -n homepage -l app=homepage -o jsonpath='{.items[0].metadata.name}') -- cat /app/services/services.yaml
```

### Debugging Tips

1. **Check Pod Logs**: Always start with logs
2. **Verify ConfigMaps**: Ensure all ConfigMaps are created
3. **Test Service Directly**: Use port-forward to test
4. **Validate YAML**: Check configuration file syntax
5. **Review Events**: Check Kubernetes events for clues

## 📊 Performance Tuning

### Resource Optimization

For larger deployments (50+ services):

```yaml
resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```

### Configuration Optimization

- **Limit Service Count**: Keep service cards under 50 for best performance
- **Optimize Widgets**: Disable unused widgets
- **Cache Icons**: Use local icon files for better performance

## 🎓 Best Practices

1. **Organize Services by Category**
   - Group related services together
   - Use descriptive category names
   - Keep categories manageable (5-10 services each)

2. **Use Descriptive Names**
   - Clear service names and descriptions
   - Consistent naming conventions
   - Include environment indicators (prod, staging, dev)

3. **Regular Maintenance**
   - Update service URLs when they change
   - Remove unused services
   - Keep icons and descriptions current

4. **Security Considerations**
   - Use HTTPS for all service links
   - Avoid exposing sensitive information in descriptions
   - Regularly review and update bookmarks

## 🔗 Useful Links

- **Official Website**: https://gethomepage.dev/
- **GitHub Repository**: https://github.com/gethomepage/homepage
- **Documentation**: https://gethomepage.dev/docs/
- **Community**: https://github.com/gethomepage/homepage/discussions

## 📝 Maintenance

### Regular Maintenance Tasks

- **Weekly**: Review service status and update descriptions
- **Monthly**: Check for new service integrations
- **Quarterly**: Review and update bookmarks
- **Yearly**: Audit configuration and optimize performance

### Updating Homepage

```bash
# Update image version in deployment.yaml
# Then apply changes
kubectl apply -k .

# Or update image directly
kubectl set image deployment/homepage homepage=ghcr.io/gethomepage/homepage:latest -n homepage
```

### Backup Configuration

```bash
# Backup all ConfigMaps
kubectl get configmaps -n homepage -o yaml > homepage-config-backup.yaml

# Restore from backup
kubectl apply -f homepage-config-backup.yaml
```

---

**🎉 Homepage Dashboard is now your central homelab hub!**

For support or questions, check the official documentation or community forums.

















