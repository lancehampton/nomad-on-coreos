# uCore + Nomad Single-Node Learning Lab

Learn immutable Linux and HashiCorp Nomad by deploying a single-node container orchestration setup using **uCore** (batteries-included Fedora CoreOS).

> **Project Status**: Complete weekend learning exercise. Successfully deployed full stack with service discovery and load balancing. **Key finding**: While technically functional, Kubernetes ecosystem maturity provides better long-term value for homelab orchestration. See [Project Takeaways](#project-takeaways--lessons-learned) for detailed analysis.

## Why uCore?

- **Immutable & Secure**: Filesystem immutability with automatic security updates
- **Batteries Included**: Tailscale, ZFS, Podman, Cockpit pre-installed
- **Low Maintenance**: Declarative configuration, automatic updates

## Quick Start

### 1. Prepare Configuration
```bash
# 1. Configure your credentials in terraform.tfvars
cd coreos/infra
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars # Add your SSH public key and password hash

# 2. Generate secure Ignition configuration
tofu init
tofu apply # Creates ignition.json with interpolated secrets
```

### 2. Create Bootable USB
```bash
# Download Fedora CoreOS ISO (base for uCore)
curl -LO https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/42.20250705.3.0/x86_64/fedora-coreos-42.20250705.3.0-live-iso.x86_64.iso
# Use Balena Etcher or similar to flash USB drive
```

### 3. Serve Ignition Config
```bash
# From your Mac/development machine (in coreos/infra directory)
python3 -m http.server 8080 --bind 0.0.0.0

# Get your machine's IP address
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### 4. Install uCore on Target Hardware
```bash
# Boot target machine from USB drive first, then run these commands from the live environment:

# Download ignition config from your development machine
curl -O http://YOUR_DEV_MACHINE_IP:8080/ignition.json

# Check target disk (usually /dev/sda or /dev/nvme0n1)
lsblk

# Install Fedora CoreOS with the ignition config (will auto-rebase to uCore)
sudo coreos-installer install /dev/nvme0n1 --ignition-file ignition.json

# Reboot into the installed system
sudo reboot
```

### 5. Verify uCore Installation
```bash
# After automatic reboot cycle completes, SSH to your system
ssh -i ~/.ssh/ucore_homelab_ed25519 core@TARGET_MACHINE_IP

# Verify uCore is running
rpm-ostree status

# Check services are ready
systemctl status nomad-agent.service consul.service tailscaled.service

# Access web UIs (firewall auto-configured)
# Nomad UI: http://TARGET_MACHINE_IP:4646
# Cockpit UI: http://TARGET_MACHINE_IP:9090

# If services fail, check preparation services
systemctl status prepare-nomad-binary.service prepare-consul-binary.service
journalctl -u prepare-nomad-binary.service
```

### 6. Deploy Nomad Jobs
```bash
# From your development machine
cd nomad/infra
tofu init
tofu apply                     # Deploy container workloads
```

## What Happens During Installation

1. **CoreOS Installation**: Base immutable OS installed from live ISO
2. **Auto-Rebase**: System automatically rebases to uCore on first boot
3. **Automatic Reboot**: System reboots to activate uCore enhancements
4. **Ready State**: uCore running with Nomad/Consul/Tailscale configured

The auto-rebase service ensures you get the full uCore experience with all batteries included.

## Architecture

- **uCore**: Immutable Fedora CoreOS with security focus
- **Ignition**: Declarative system configuration (YAML)
- **Nomad**: Single-node container orchestration
- **Consul**: Service discovery and configuration
- **Podman**: Container runtime (built into uCore)
- **Tailscale**: Zero-config VPN (pre-installed)

## Directory Structure
```
nomad-on-coreos/
├── coreos/
│   ├── ignition/               # Butane configs (.yaml)
│   └── infra/                  # Transpiles Butane to Ignition
└── nomad/
    ├── jobs/                   # Nomad job definitions (.hcl)
    └── infra/                  # OpenTofu for job deployment
```

## Learning Focus

This is a **learning project** optimized for understanding uCore and Nomad fundamentals:

- ✅ Single-node simplicity
- ✅ Direct tool exposure (minimal abstractions)
- ✅ Weekend timeline (hours, not weeks)
- ✅ Immutable security patterns
- ✅ Container orchestration comparison with Kubernetes

**Not** a production-ready multi-node cluster.

## Project Takeaways & Lessons Learned

After building this complete single-node container orchestration setup, here are the key findings:

### **Technical Achievements**
- **uCore deployment successful**: Auto-rebase from Fedora CoreOS works seamlessly
- **Immutable infrastructure**: Declarative configuration with Ignition/Butane is solid
- **Container orchestration**: Nomad + Consul + Podman stack functional with service discovery
- **Load balancing**: Traefik integration with Consul service registry working correctly
- **Infrastructure as Code**: OpenTofu manages entire stack deployment reliably

### **Nomad vs Kubernetes Reality Check**

**Initial Promise**: "Simpler than Kubernetes for small deployments"

**Assessment** (based on hands-on experience with both platforms):
- **Job specification complexity**: Nomad job specs vs Kubernetes deployments - just different, not simpler. Same configuration complexity for networking, resources, health checks, etc.
- **Control plane**: Single binary vs multiple services is already solved (k3s, minikube, managed K8s)
- **Ecosystem depth**: Kubernetes has more options for everything (storage, networking, scaling, workload types); Nomad focuses on consistent patterns
- **Perceived vs actual complexity**: Kubernetes appears overwhelming due to its vast ecosystem, but simple deployments are equally straightforward in both
- **Community & tooling**: Much easier to find help, tools, and solutions for Kubernetes

### **When Nomad Makes Sense**
- **Pure HashiCorp shops**: Tight integration with Vault, Consul, Terraform workflows
- **Specific compliance**: Environments requiring HashiCorp Enterprise support/features
- **Resource constraints**: Truly minimal deployments where K8s overhead matters
- **Learning HashiCorp**: Understanding their ecosystem before adopting Vault/Consul

## License

MIT License - see LICENSE file.
