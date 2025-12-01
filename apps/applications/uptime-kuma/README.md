# 🔍 Uptime Kuma - Service Monitoring

A beautiful, self-hosted monitoring tool for tracking the uptime and health of all your homelab services.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Monitoring Targets](#monitoring-targets)
- [Notifications](#notifications)
- [n8n Integration](#n8n-integration)
- [Status Pages](#status-pages)
- [Backup & Restore](#backup--restore)
- [Troubleshooting](#troubleshooting)
- [Security](#security)

## 🎯 Overview

Uptime Kuma is a fancy self-hosted monitoring tool that provides:

- **Beautiful Dashboard**: Modern, responsive UI with dark mode
- **Multi-Protocol Support**: HTTP(s), TCP, Ping, DNS, Docker, and more
- **90+ Notification Channels**: Email, Slack, Discord, Telegram, Webhooks, and more
- **Status Pages**: Public/private status pages for your services
- **Performance Metrics**: Response time tracking and uptime statistics
- **Certificate Monitoring**: TLS certificate expiration tracking

## ✨ Features

### Monitoring Capabilities

- ✅ **HTTP(s) Monitoring** - Check web services and APIs
- ✅ **TCP Port Monitoring** - Monitor any TCP port
- ✅ **Ping Monitoring** - ICMP ping checks
- ✅ **DNS Monitoring** - DNS query validation
- ✅ **Keyword Monitoring** - Check for specific content on pages
- ✅ **Certificate Expiry** - SSL/TLS certificate monitoring
- ✅ **JSON Query** - Monitor API responses with JSON path
- ✅ **Docker Container** - Monitor Docker container status

### Alert & Notification Features

- 🔔 **90+ Notification Services** - Discord, Slack, Telegram, Email, Pushover, etc.
- 🔔 **Webhook Support** - Integrate with n8n, Zapier, custom services
- 🔔 **Multi-Channel Notifications** - Send to multiple channels per monitor
- 🔔 **Repeat Notifications** - Re-alert if service stays down
- 🔔 **Maintenance Windows** - Schedule maintenance to prevent false alerts

### Dashboard & Reporting

- 📊 **Real-time Dashboard** - Live status of all monitors
- 📊 **Historical Data** - Uptime statistics and response time graphs
- 📊 **Status Pages** - Public/private status pages for stakeholders
- 📊 **Uptime Badges** - Embeddable badges for documentation
- 📊 **Mobile Responsive** - Works great on phones and tablets

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   Uptime Kuma Architecture               │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────┐     │
│  │         Web Interface (Port 3001)              │     │
│  │  - Dashboard                                   │     │
│  │  - Configuration                               │     │
│  │  - Status Pages                                │     │
│  └────────────────────────────────────────────────┘     │
│              ↓                    ↓                      │
│  ┌─────────────────┐   ┌──────────────────────┐        │
│  │  SQLite Database│   │  Monitoring Engine   │        │
│  │  (/app/data)    │   │  - Schedulers        │        │
│  │  - Monitors     │   │  - Checks            │        │
│  │  - Notifications│   │  - Notifications     │        │
│  │  - Status Pages │   │  - Data Collection   │        │
│  │  - Settings     │   └──────────────────────┘        │
│  └─────────────────┘              ↓                     │
│         ↓                          ↓                     │
│  ┌──────────────────────────────────────────────┐       │
│  │      Local-Path Persistent Volume (2Gi)      │       │
│  │      - SQLite database file                  │       │
│  │      - Configuration backups                 │       │
│  │      - Historical data                       │       │
│  └──────────────────────────────────────────────┘       │
│                                                          │
│  External Access via Traefik Ingress:                   │
│  https://uptime.katrelleslab.org                        │
│                                                          │
└──────────────────────────────────────────────────────────┘
         ↓    ↓    ↓    ↓    ↓    ↓    ↓    ↓
    ┌────┴────┴────┴────┴────┴────┴────┴────────┐
    │         Monitored Services                 │
    ├────────────────────────────────────────────┤
    │ • n8n.katrelleslab.org                     │
    │ • pihole-primary.katrelleslab.org          │
    │ • pihole-secondary.katrelleslab.org        │
    │ • argocd.katrelleslab.org                  │
    │ • grafana.katrelleslab.org                 │
    │ • longhorn.katrelleslab.org                │
    │ • K3s API Server (Internal)                │
    │ • Custom Services...                       │
    └────────────────────────────────────────────┘
```

## 📦 Prerequisites

Before deploying Uptime Kuma, ensure you have:

- ✅ **K3s Cluster**: Running K3s cluster with at least 1 node
- ✅ **Local-Path Storage**: Installed and configured for persistent storage (SQLite compatible)
- ✅ **Traefik Ingress**: Configured ingress controller
- ✅ **Cert-Manager**: For automatic TLS certificate management
- ✅ **DNS Configuration**: `uptime.katrelleslab.org` pointing to your cluster

### Resource Requirements

- **CPU**: 100m request, 500m limit
- **Memory**: 128Mi request, 512Mi limit
- **Storage**: 2Gi persistent volume (local-path)

## 🚀 Quick Start

### 1. Clone or Navigate to Directory

```bash
cd /home/trelle/k3s/applications/uptime-kuma
```

### 2. Deploy to Kubernetes

```bash
# Deploy using Kustomize
kubectl apply -k .

# Or deploy individually
kubectl apply -f namespace.yaml
kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

### 3. Verify Deployment

```bash
# Check pod status
kubectl get pods -n uptime-kuma

# Check logs
kubectl logs -n uptime-kuma -l app=uptime-kuma

# Check ingress
kubectl get ingress -n uptime-kuma
```

### 4. Access Uptime Kuma

Navigate to: **https://uptime.katrelleslab.org**

On first access, you'll be prompted to create an admin account.

## ⚙️ Configuration

### First-Time Setup

1. **Access the Interface**: Open `https://uptime.katrelleslab.org`
2. **Create Admin Account**:
   - Username: Choose a secure username
   - Password: Use a strong password (store in password manager)
   - Email: Your notification email

3. **Configure Settings**:
   - Go to Settings → General
   - Set timezone: `America/New_York`
   - Configure default notification list
   - Set up primary language

### Environment Variables

The deployment includes the following environment variables:

```yaml
env:
- name: UPTIME_KUMA_PORT
  value: "3001"
- name: TZ
  value: "America/New_York"
```

To modify these, edit `deployment.yaml` and reapply.

### Kubernetes-Specific Configuration

This deployment includes several Kubernetes-specific optimizations:

```yaml
# Custom startup command to bypass permission issues
command: ["/bin/sh", "-c"]
args:
  - |
    node server/server.js

# Environment variables for proper operation
env:
- name: PUID
  value: "0"
- name: PGID
  value: "0"
- name: UPTIME_KUMA_PORT
  value: "3001"
- name: TZ
  value: "America/New_York"
- name: NODE_ENV
  value: "production"

# Storage configuration
storageClassName: local-path  # SQLite-compatible storage
```

**Important Notes:**
- Uses `local-path` storage class for better SQLite compatibility
- Bypasses the default startup script to avoid permission issues
- Runs as root user (required for this image in Kubernetes)
- Optimized for K3s cluster environments

## 🎯 Monitoring Targets

### Recommended Services to Monitor

Here's a comprehensive list of services you should monitor:

#### Core Applications

1. **n8n Workflow Automation**
   - URL: `https://n8n.katrelleslab.org`
   - Type: HTTP(s)
   - Check: 200 status code
   - Interval: 60 seconds
   - Keyword: "n8n" (optional)

2. **Pi-hole Primary**
   - URL: `https://pihole-primary.katrelleslab.org/admin`
   - Type: HTTP(s)
   - Check: 200 status code
   - Interval: 60 seconds

3. **Pi-hole Secondary**
   - URL: `https://pihole-secondary.katrelleslab.org/admin`
   - Type: HTTP(s)
   - Check: 200 status code
   - Interval: 60 seconds

4. **ArgoCD**
   - URL: `https://argocd.katrelleslab.org`
   - Type: HTTP(s)
   - Check: 200 status code
   - Interval: 120 seconds

#### Monitoring & Infrastructure

5. **Grafana**
   - URL: `https://grafana.katrelleslab.org`
   - Type: HTTP(s)
   - Check: 200 status code
   - Interval: 120 seconds

6. **Prometheus**
   - URL: `https://prometheus.katrelleslab.org`
   - Type: HTTP(s)
   - Check: 200 status code
   - Interval: 120 seconds

7. **Longhorn UI**
   - URL: `https://longhorn.katrelleslab.org`
   - Type: HTTP(s)
   - Check: 200 status code
   - Interval: 120 seconds

#### Internal Services

8. **K3s API Server**
   - URL: `https://kubernetes.default.svc:443`
   - Type: TCP Port
   - Port: 443
   - Interval: 60 seconds

9. **DNS Service (CoreDNS)**
   - Host: `kube-dns.kube-system.svc.cluster.local`
   - Type: DNS
   - Record Type: A
   - Interval: 120 seconds

### Certificate Monitoring

Monitor all your TLS certificates for expiration:

- `*.katrelleslab.org` - Wildcard certificate
- Check 30 days before expiry
- Alert 15 days before expiry

## 🔔 Notifications

### Setting Up Notifications

Uptime Kuma supports 90+ notification services. Here are the most common:

#### Email Notifications

1. Go to **Settings** → **Notifications**
2. Click **Setup Notification**
3. Select **Email (SMTP)**
4. Configure:
   ```
   Friendly Name: Homelab Alerts
   SMTP Host: smtp.gmail.com
   SMTP Port: 587
   Security: TLS
   Username: your-email@gmail.com
   Password: [App Password]
   From Email: your-email@gmail.com
   To Email: your-email@gmail.com
   ```
5. Test the notification
6. Click **Save**

#### Discord Webhook

1. Create a webhook in Discord server
2. In Uptime Kuma: **Settings** → **Notifications** → **Setup Notification**
3. Select **Discord**
4. Paste webhook URL
5. Test and save

#### Slack Webhook

1. Create a webhook in Slack workspace
2. In Uptime Kuma: **Settings** → **Notifications** → **Setup Notification**
3. Select **Slack**
4. Paste webhook URL
5. Test and save

#### Telegram

1. Create a bot with BotFather
2. Get bot token and chat ID
3. In Uptime Kuma: **Settings** → **Notifications** → **Setup Notification**
4. Select **Telegram**
5. Enter bot token and chat ID
6. Test and save

## 🔗 n8n Integration

Uptime Kuma can trigger n8n workflows via webhooks, enabling powerful automation.

### Setting Up n8n Webhook

1. **Create n8n Workflow**:
   - Start with a **Webhook** trigger node
   - Add your automation logic (send alerts, create tickets, etc.)
   - Activate the workflow

2. **Get Webhook URL**:
   - Copy the production webhook URL from n8n
   - Example: `https://n8n.katrelleslab.org/webhook/uptime-alert`

3. **Configure in Uptime Kuma**:
   - Go to **Settings** → **Notifications** → **Setup Notification**
   - Select **Webhook**
   - Enter URL: `https://n8n.katrelleslab.org/webhook/uptime-alert`
   - Method: POST
   - Content Type: application/json
   - Body:
     ```json
     {
       "monitor": "[[MONITOR_NAME]]",
       "status": "[[STATUS]]",
       "message": "[[MESSAGE]]",
       "time": "[[TIME]]",
       "url": "[[URL]]"
     }
     ```

4. **Test the Integration**

### Example n8n Workflow

See `n8n-integration/webhook-example.json` for a complete n8n workflow that:
- Receives alerts from Uptime Kuma
- Logs to database
- Sends formatted notifications
- Creates incident tickets (optional)

### Automation Ideas

- **Auto-restart services** when they go down
- **Create tickets** in your issue tracker
- **Send SMS** for critical alerts
- **Update status pages** automatically
- **Log incidents** to database
- **Escalate** to on-call personnel

## 📄 Status Pages

### Creating a Status Page

1. Go to **Status Pages**
2. Click **New Status Page**
3. Configure:
   - **Slug**: `homelab-status`
   - **Title**: "Homelab Services Status"
   - **Description**: "Real-time status of homelab infrastructure"
   - **Theme**: Choose light/dark
   - **Show Tags**: Enable
   - **Public**: Choose visibility

4. **Add Monitors**:
   - Drag monitors to the status page
   - Group by category (Applications, Infrastructure, etc.)
   - Customize display order

5. **Save and Publish**

### Access Status Page

- Public: `https://uptime.katrelleslab.org/status/homelab-status`
- Can be embedded in other sites
- Mobile responsive

## 💾 Backup & Restore

### Backup Strategy

Uptime Kuma stores all data in a SQLite database at `/app/data/kuma.db`.

#### Manual Backup

```bash
# Copy database from pod
kubectl exec -n uptime-kuma $(kubectl get pod -n uptime-kuma -l app=uptime-kuma -o jsonpath='{.items[0].metadata.name}') -- cp /app/data/kuma.db /app/data/kuma.db.backup

# Download backup
kubectl cp uptime-kuma/$(kubectl get pod -n uptime-kuma -l app=uptime-kuma -o jsonpath='{.items[0].metadata.name}'):/app/data/kuma.db.backup ./kuma-backup-$(date +%Y%m%d).db
```

#### Automated Backup with n8n

Create an n8n workflow to:
1. Run on schedule (daily at 2 AM)
2. Execute backup command via Kubernetes API
3. Upload to cloud storage (S3, Google Drive, etc.)
4. Rotate old backups (keep last 30 days)

### Restore from Backup

```bash
# Stop deployment
kubectl scale deployment uptime-kuma -n uptime-kuma --replicas=0

# Upload backup to pod
kubectl cp ./kuma-backup-20240117.db uptime-kuma/$(kubectl get pod -n uptime-kuma -l app=uptime-kuma -o jsonpath='{.items[0].metadata.name}'):/app/data/kuma.db

# Start deployment
kubectl scale deployment uptime-kuma -n uptime-kuma --replicas=1
```

## 🔧 Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl get pods -n uptime-kuma

# Check pod events
kubectl describe pod -n uptime-kuma -l app=uptime-kuma

# Check logs
kubectl logs -n uptime-kuma -l app=uptime-kuma
```

### Common Issues

#### Issue: Pod in CrashLoopBackOff

**Cause**: Permission issues with startup script or storage compatibility

**Common Error Messages**:
- `chown: changing ownership of '/app/data': Operation not permitted`
- `setpriv: setgroups failed: Operation not permitted`

**Solution**:
```bash
# Check PVC status and storage class
kubectl get pvc -n uptime-kuma

# Check pod logs for specific error
kubectl logs -n uptime-kuma -l app=uptime-kuma

# Verify storage class is local-path (not longhorn)
kubectl get pvc uptime-kuma-pvc -n uptime-kuma -o jsonpath='{.spec.storageClassName}'
```

**If using Longhorn storage**:
- Switch to `local-path` storage class for better SQLite compatibility
- Update `pvc.yaml` with `storageClassName: local-path`

#### Issue: Cannot Access Web Interface

**Cause**: Ingress or service misconfiguration

**Solution**:
```bash
# Check ingress
kubectl get ingress -n uptime-kuma

# Check service
kubectl get svc -n uptime-kuma

# Test service directly
kubectl port-forward -n uptime-kuma svc/uptime-kuma 3001:3001
# Access at http://localhost:3001
```

#### Issue: Monitors Not Working

**Cause**: Network policies or DNS issues

**Solution**:
```bash
# Test from pod
kubectl exec -n uptime-kuma $(kubectl get pod -n uptime-kuma -l app=uptime-kuma -o jsonpath='{.items[0].metadata.name}') -- curl -I https://n8n.katrelleslab.org

# Check DNS
kubectl exec -n uptime-kuma $(kubectl get pod -n uptime-kuma -l app=uptime-kuma -o jsonpath='{.items[0].metadata.name}') -- nslookup n8n.katrelleslab.org
```

### Debugging Tips

1. **Check Pod Logs**: Always start with logs
2. **Verify DNS**: Ensure DNS resolution works
3. **Test Connectivity**: Use kubectl exec to test from pod
4. **Check Resources**: Ensure pod has enough CPU/memory
5. **Review Events**: Check Kubernetes events for clues

## 🔒 Security

### Security Best Practices

1. **Strong Admin Password**
   - Use password manager
   - Enable 2FA (if available)
   - Rotate regularly

2. **Network Security**
   - Uptime Kuma runs as root user (required for this image in Kubernetes)
   - Read-only root filesystem disabled (SQLite needs write access)
   - All capabilities dropped except those required for operation

3. **Access Control**
   - Ingress protected by TLS
   - Consider adding basic auth at Traefik level
   - Use private status pages for internal monitoring

4. **Data Protection**
   - Database stored on local-path volume (SQLite compatible)
   - Regular backups to secure location
   - Backup encryption (optional)

5. **API Security**
   - Disable public API if not needed
   - Use API keys for integrations
   - Rotate API keys regularly

### Security Context

The deployment includes these security settings:

```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false  # SQLite needs write access
  runAsNonRoot: false
  runAsUser: 0
  capabilities:
    drop:
    - ALL
```

## 📊 Performance Tuning

### Resource Optimization

For larger deployments (100+ monitors):

```yaml
resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```

### Database Optimization

- **Regular Maintenance**: Vacuum database monthly
- **Data Retention**: Configure heartbeat retention (default: 180 days)
- **Monitor Intervals**: Balance between freshness and load

## 🎓 Best Practices

1. **Organize Monitors with Tags**
   - `critical`, `warning`, `info`
   - `application`, `infrastructure`, `external`
   - `production`, `staging`, `development`

2. **Set Appropriate Intervals**
   - Critical services: 60 seconds
   - Standard services: 120 seconds
   - Low priority: 300 seconds

3. **Use Maintenance Windows**
   - Schedule during known maintenance
   - Prevents false alerts
   - Improves alert quality

4. **Monitor the Monitor**
   - Set up external monitoring for Uptime Kuma itself
   - Use different provider (UptimeRobot, Pingdom, etc.)
   - Get alerted if Uptime Kuma goes down

5. **Document Everything**
   - Document what each monitor checks
   - Document expected response times
   - Keep runbooks for alerts

## 🔗 Useful Links

- **Official Website**: https://uptime.kuma.pet/
- **GitHub Repository**: https://github.com/louislam/uptime-kuma
- **Documentation**: https://github.com/louislam/uptime-kuma/wiki
- **Community**: https://github.com/louislam/uptime-kuma/discussions

## 📝 Maintenance

### Regular Maintenance Tasks

- **Weekly**: Review alert accuracy and false positives
- **Monthly**: Check disk usage and optimize database
- **Quarterly**: Review and update monitoring targets
- **Yearly**: Audit notification channels and contacts

### Updating Uptime Kuma

```bash
# Update image version in deployment.yaml
# Then apply changes
kubectl apply -k .

# Or update image directly
kubectl set image deployment/uptime-kuma uptime-kuma=louislam/uptime-kuma:1 -n uptime-kuma
```

---

**🎉 Uptime Kuma is now monitoring your homelab!**

For support or questions, check the official documentation or community forums.

