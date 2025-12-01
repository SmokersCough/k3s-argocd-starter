# 🏠 Homepage K3s Services Integration Roadmap

## 📊 Current K3s Services Analysis

### ✅ Services Currently Running
- **Pi-hole Primary**: `pihole.katrelleslab.org` (LoadBalancer + Ingress)
- **Pi-hole Secondary**: `pihole2.katrelleslab.org` (LoadBalancer + Ingress) 
- **n8n**: `n8n.katrelleslab.org` (ClusterIP + Ingress)
- **Uptime Kuma**: `uptime.katrelleslab.org` (ClusterIP + Ingress)
- **Grafana**: `prometheus-grafana` service in monitoring namespace
- **Prometheus**: Available in monitoring namespace

### ❌ Services Not Found
- ArgoCD (not currently deployed)
- Portainer (not currently deployed)

## 🎯 Integration Roadmap

### Phase 1: Basic Service Integration (Week 1)

#### 1.1 Pi-hole Widgets (High Priority)
- **Status**: ✅ Ready to implement
- **Configuration**: Pi-hole widgets are well-supported in Homepage
- **Requirements**: 
  - Pi-hole API key (from admin interface)
  - Correct API endpoints
- **Expected Result**: Real-time DNS queries, blocked domains, uptime stats
- **Implementation**:
  ```yaml
  - Pi-hole Primary:
      href: https://pihole.katrelleslab.org/admin
      icon: pihole.png
      description: "Primary DNS server with ad-blocking capabilities"
      widget:
        type: pihole
        url: https://pihole.katrelleslab.org/admin
        key: pihole-primary
  ```

#### 1.2 Uptime Kuma Integration
- **Status**: ⚠️ Limited widget support
- **Configuration**: Basic service monitoring only
- **Requirements**: 
  - Uptime Kuma API access
  - Service status endpoints
- **Expected Result**: Service status indicators, uptime percentages
- **Implementation**:
  ```yaml
  - Uptime Kuma:
      href: https://uptime.katrelleslab.org
      icon: uptime-kuma.png
      description: "Real-time monitoring and status page for all services"
      # Note: No widget support, service link only
  ```

#### 1.3 n8n Integration
- **Status**: ❌ No official widget support
- **Configuration**: Service link only (no widgets)
- **Requirements**: None (just URL access)
- **Expected Result**: Direct link to n8n interface
- **Implementation**:
  ```yaml
  - n8n:
      href: https://n8n.katrelleslab.org
      icon: n8n.png
      description: "Visual workflow automation platform for connecting apps and services"
      # Note: No widget support, service link only
  ```

### Phase 2: Advanced Monitoring (Week 2)

#### 2.1 Grafana Integration
- **Status**: ✅ Widget support available
- **Configuration**: Requires API key and proper authentication
- **Requirements**:
  - Grafana API key
  - Dashboard IDs for monitoring
- **Expected Result**: Dashboard previews, alert status, metrics
- **Implementation**:
  ```yaml
  - Grafana:
      href: https://grafana.katrelleslab.org
      icon: grafana.png
      description: "Metrics visualization and monitoring dashboards"
      widget:
        type: grafana
        url: https://grafana.katrelleslab.org
        key: grafana
  ```

#### 2.2 Prometheus Integration
- **Status**: ✅ Widget support available
- **Configuration**: Requires proper API configuration
- **Requirements**:
  - Prometheus API access
  - Query endpoints
- **Expected Result**: Metrics display, alert status
- **Implementation**:
  ```yaml
  - Prometheus:
      href: https://prometheus.katrelleslab.org
      icon: prometheus.png
      description: "Time-series database and monitoring system"
      widget:
        type: prometheus
        url: https://prometheus.katrelleslab.org
        key: prometheus
  ```

#### 2.3 Kubernetes Integration
- **Status**: ✅ Native support
- **Configuration**: Cluster monitoring widgets
- **Requirements**:
  - Kubernetes API access
  - RBAC permissions
- **Expected Result**: Pod status, resource usage, cluster health
- **Implementation**:
  ```yaml
  # In widgets.yaml
  - kubernetes:
      namespaces: ["default", "homepage", "monitoring", "n8n", "pihole", "uptime-kuma"]
  ```

### Phase 3: Enhanced Features (Week 3)

#### 3.1 Docker Monitoring
- **Status**: ✅ Native support
- **Configuration**: Container monitoring
- **Requirements**:
  - Docker socket access
  - Container labels
- **Expected Result**: Container status, resource usage
- **Implementation**:
  ```yaml
  # In widgets.yaml
  - docker:
      containers: ["homepage", "pihole-primary", "pihole-secondary"]
  ```

#### 3.2 Weather Widget
- **Status**: ✅ Native support
- **Configuration**: External API integration
- **Requirements**:
  - OpenWeatherMap API key
  - Location configuration
- **Expected Result**: Current weather, forecasts
- **Implementation**:
  ```yaml
  # In widgets.yaml
  - weather:
      location: "New York, NY"
      units: "imperial"
      provider: "openweathermap"
  ```

#### 3.3 System Resources Widget
- **Status**: ✅ Already configured
- **Configuration**: Enhanced monitoring
- **Requirements**: None (already working)
- **Expected Result**: CPU, memory, disk usage
- **Current Implementation**:
  ```yaml
  # In widgets.yaml
  - resources:
      cpu: true
      memory: true
      disk: /
  ```

### Phase 4: Optional Services (Week 4)

#### 4.1 ArgoCD Deployment
- **Status**: ❌ Not currently deployed
- **Configuration**: Deploy ArgoCD to cluster
- **Requirements**:
  - ArgoCD deployment
  - API token configuration
- **Expected Result**: GitOps status, application health
- **Implementation Steps**:
  1. Deploy ArgoCD to K3s cluster
  2. Configure ingress for external access
  3. Generate API token
  4. Add widget configuration

#### 4.2 Portainer Deployment
- **Status**: ❌ Not currently deployed
- **Configuration**: Deploy Portainer to cluster
- **Requirements**:
  - Portainer deployment
  - API key configuration
- **Expected Result**: Container management, Docker stats
- **Implementation Steps**:
  1. Deploy Portainer to K3s cluster
  2. Configure ingress for external access
  3. Generate API key
  4. Add widget configuration

## 🔑 API Keys and Configuration Requirements

### Required API Keys
1. **Pi-hole**: Admin interface → Settings → API → Show API key
2. **Grafana**: Admin → API Keys → New API Key
3. **OpenWeatherMap**: Sign up at openweathermap.org
4. **Uptime Kuma**: Settings → API (if available)

### Configuration Files to Update
1. **`settings.yaml`**: Add API keys and provider configurations
2. **`services.yaml`**: Add proper widget configurations
3. **`widgets.yaml`**: Add monitoring and system widgets
4. **`deployment.yaml`**: Add environment variables for API keys

## 📋 Implementation Steps

### Step 1: Gather API Keys
- [ ] Access Pi-hole admin interface and get API key
- [ ] Access Grafana admin interface and create API key
- [ ] Sign up for OpenWeatherMap API key
- [ ] Check Uptime Kuma for API access
- [ ] Document all keys securely

### Step 2: Update Configuration Files
- [ ] Add API keys to `settings.yaml`
- [ ] Configure Pi-hole widgets in `services.yaml`
- [ ] Add Grafana and Prometheus widgets
- [ ] Add Kubernetes monitoring widgets
- [ ] Add weather widget configuration

### Step 3: Test Integration
- [ ] Deploy configuration changes
- [ ] Verify Pi-hole widgets work
- [ ] Test Grafana integration
- [ ] Verify Kubernetes monitoring
- [ ] Test weather widget

### Step 4: Deploy Optional Services
- [ ] Deploy ArgoCD if desired
- [ ] Deploy Portainer if desired
- [ ] Configure their widgets
- [ ] Test integration

## 🎯 Expected Final Result

A fully integrated Homepage dashboard with:
- **Real-time Pi-hole monitoring** (queries, blocked domains)
- **Service status monitoring** (Uptime Kuma integration)
- **Grafana dashboards** (metrics and alerts)
- **Kubernetes cluster monitoring** (pods, resources)
- **System resource monitoring** (CPU, memory, disk)
- **Weather information** (current conditions)
- **Direct service access** (n8n, Grafana, etc.)

## ⚠️ Important Notes

1. **Security**: Store API keys securely, consider using Kubernetes secrets
2. **Rate Limits**: Be aware of API rate limits for external services
3. **Authentication**: Some services may require additional authentication setup
4. **Network Access**: Ensure Homepage can access internal services
5. **Updates**: Keep configurations updated as services change

## 🚀 Quick Start Commands

```bash
# Navigate to homepage directory
cd /home/trelle/k3s/applications/homepage

# Apply configuration changes
kubectl apply -k .

# Restart deployment
kubectl rollout restart deployment/homepage -n homepage

# Check logs
kubectl logs -n homepage -l app=homepage --follow

# Test access
curl -I https://homepage.katrelleslab.org
```

## 📚 Additional Resources

- [Homepage Documentation](https://gethomepage.dev/)
- [Homepage Widgets](https://gethomepage.dev/widgets/)
- [Homepage Services](https://gethomepage.dev/services/)
- [Pi-hole API Documentation](https://docs.pi-hole.net/ftldns/api/)
- [Grafana API Documentation](https://grafana.com/docs/grafana/latest/http_api/)

---

**Last Updated**: October 18, 2025
**Status**: Ready for implementation
**Priority**: Phase 1 (Pi-hole integration) - High
