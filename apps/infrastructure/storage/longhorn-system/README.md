# Longhorn Storage Configuration

## Automatic Disk Creation

Longhorn is configured to **automatically create default disks on ALL nodes** when they join the cluster. No manual labeling or configuration is required.

### Configuration

The following settings are enabled in `values.yaml`:

```yaml
defaultSettings:
  createDefaultDiskLabeledNodes: false  # false = create disks on all nodes automatically
  defaultDataPath: /var/lib/longhorn
```

### How It Works

With `createDefaultDiskLabeledNodes: false`:
- **All nodes** that join the cluster will automatically get a default disk
- Disks are created at `/var/lib/longhorn` (configurable via `defaultDataPath`)
- No manual intervention required

### Adding New Nodes

When adding new nodes to the cluster:

1. **Join the node to the cluster** (via K3s or your method)
2. **That's it!** Longhorn will automatically:
   - Discover the node
   - Create a default disk at `/var/lib/longhorn`
   - Make the disk available for storage

No labeling or manual configuration needed.

### Verification

Check Longhorn node status:

```bash
kubectl get nodes.longhorn.io -n longhorn-system
```

### Manual Disk Configuration

If automatic disk creation doesn't work, you can manually add disks:

```bash
kubectl patch nodes.longhorn.io <node-name> -n longhorn-system \
  --type merge \
  -p '{
    "spec": {
      "disks": {
        "default-disk": {
          "allowScheduling": true,
          "evictionRequested": false,
          "path": "/var/lib/longhorn",
          "storageReserved": 0
        }
      }
    }
  }'
```

### Notes

- The default disk path is `/var/lib/longhorn` (configurable via `defaultDataPath` setting)
- Disks are created with `allowScheduling: true` by default
- `storageReserved: 0` means all available space can be used for storage
- Only nodes with the label will have disks created automatically

