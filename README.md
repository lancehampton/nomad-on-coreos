# uCore + Nomad Single-Node Learning Lab

Learn immutable Linux and HashiCorp Nomad by deploying a single-node container orchestration setup using **uCore** (batteries-included Fedora CoreOS).

## Why uCore?

- **🛡️ Immutable & Secure**: Filesystem immutability with automatic security updates
- **📦 Batteries Included**: Tailscale, ZFS, Podman, Cockpit pre-installed
- **🔧 Low Maintenance**: Declarative configuration, automatic updates

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
├── nomad/
│   ├── jobs/                   # Nomad job definitions (.hcl)
│   └── infra/                  # OpenTofu for job deployment
└── docs/                       # Learning documentation
```

## Tools

- **OpenTofu** for infrastructure-as-code
- **Butane** for human-readable system configuration
- Direct SSH access for debugging and learning

## Learning Focus

This is a **learning project** optimized for understanding uCore and Nomad fundamentals:

- ✅ Single-node simplicity (no multi-node complexity)
- ✅ Direct tool exposure (minimal abstractions)
- ✅ Weekend timeline (hours, not weeks)
- ✅ Immutable security patterns
- ✅ Container orchestration basics

**Not** a production-ready multi-node cluster.

## License

MIT License - see LICENSE file.
