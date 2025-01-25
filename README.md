# SSH Port Forwarding Script 

## Description
Bash script to set up SSH port forwarding between local and remote servers with support for password/key authentication.

## Prerequisites
- SSH access to remote server
- Remote server must have following config in `/etc/ssh/sshd_config`:
```bash
GatewayPorts yes
AllowTcpForwarding yes
GatewayPorts clientspecified
```

After modifying config:
```bash
sudo systemctl restart sshd
sudo ufw allow <remote_port>
```

## Installation
```bash
# Download script
git clone https://github.com/scorcism/port_forward

cd port_forward

# Make executable
chmod +x port-forward.sh
```

## Usage
```bash
./port-forward.sh
```
