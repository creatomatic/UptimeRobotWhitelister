
<div style="display:flex; justify-content:center;">
<img style="padding-block: 2em; height:150px" src="https://play-lh.googleusercontent.com/cUrv0t00FYQ1GKLuOTvv8qjo1lSDjqZC16IOp3Fb6ijew6Br5m4o16HhDp0GBu_Bw8Y" />
</div>


# UptimeRobot Whitelister

A bash script for automatically whitelisting UptimeRobot monitoring server IP addresses in your server's firewall using iptables and ipset.

## Overview

UptimeRobot is a popular uptime monitoring service that checks your websites and servers from multiple locations worldwide. However, if your server has strict firewall rules, UptimeRobot's monitoring requests might be blocked, leading to false downtime alerts.

This application solves that problem by:
- Creating optimized IP sets for both IPv4 and IPv6 UptimeRobot addresses
- Automatically configuring iptables rules to allow connections from these addresses
- Providing persistent rules that survive system reboots
- Offering easy management and updates of the whitelist

## Features

- **Dual Stack Support**: Handles both IPv4 and IPv6 addresses
- **Efficient IP Management**: Uses ipset for optimal performance with large IP lists
- **Idempotent Operations**: Safe to run multiple times without conflicts
- **Persistent Rules**: Optional persistence across system reboots
- **Comprehensive Logging**: Detailed timestamped logs for troubleshooting
- **Error Handling**: Graceful handling of missing files and failed operations
- **Root Privilege Check**: Ensures proper permissions before execution

## Prerequisites

- Linux system with iptables and ipset installed
- Root privileges (sudo access)
- IPv4 and/or IPv6 network stack enabled

### Installing Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install iptables ipset
```

**CentOS/RHEL/Fedora:**
```bash
sudo yum install iptables ipset
# or for newer versions:
sudo dnf install iptables ipset
```

## Installation

1. Clone or download the repository:
```bash
git clone git@github.com:creatomatic/UptimeRobotWhitelister.git
cd UptimeRobotWhitelister
```

2. Make the script executable:
```bash
chmod +x add_to_iptables.sh
```

## Usage

### Quick Start

Run the script with sudo privileges:

```bash
sudo ./add_to_iptables.sh
```

### Using the Makefile

For convenience, you can use the included Makefile:

```bash
# Make executable and run the script
make run

# Only make the script executable
make chmod-script

# Show available targets
make help
```

## What the Script Does

1. **Validates Privileges**: Ensures the script is run with root permissions
2. **Creates IP Sets**: 
   - `uptimerobot.ipv4` - Hash set for IPv4 addresses
   - `uptimerobot.ipv6` - Hash set for IPv6 addresses
3. **Loads IP Addresses**: Reads from `uptimerobot.ipv4` and `uptimerobot.ipv6` files
4. **Configures Firewall Rules**: Adds iptables/ip6tables rules to accept traffic from the IP sets
5. **Provides Summary**: Shows count of loaded addresses and rule status
6. **Optional Persistence**: Offers to save rules for automatic restoration after reboot

## File Structure

```
UptimeRobotsWhitelister/
├── add_to_iptables.sh    # Main script
├── uptimerobot.ipv4      # IPv4 addresses (114 addresses)
├── uptimerobot.ipv6      # IPv6 addresses (116 addresses)
├── makefile              # Build automation
└── README.md             # This file
```

## IP Address Lists

The application includes up-to-date lists of UptimeRobot monitoring server IP addresses:

- **IPv4**: 114 addresses from various global locations
- **IPv6**: 116 addresses supporting modern IPv6 infrastructure

These lists are maintained to reflect UptimeRobot's current monitoring infrastructure.

## Example Output

```
[2025-08-06 14:30:15] Starting UptimeRobot whitelisting process...
[2025-08-06 14:30:15] Creating IPv4 ipset: uptimerobot.ipv4
[2025-08-06 14:30:15] IPv4 ipset already exists, flushing it
[2025-08-06 14:30:15] Creating IPv6 ipset: uptimerobot.ipv6
[2025-08-06 14:30:15] IPv6 ipset already exists, flushing it
[2025-08-06 14:30:15] Adding IPv4 addresses to ipset
[2025-08-06 14:30:15] IPv4 addresses added successfully
[2025-08-06 14:30:15] Adding IPv6 addresses to ipset
[2025-08-06 14:30:15] IPv6 addresses added successfully
[2025-08-06 14:30:15] Configuring iptables rules for IPv4
[2025-08-06 14:30:15] IPv4 iptables rule added
[2025-08-06 14:30:15] Configuring ip6tables rules for IPv6
[2025-08-06 14:30:15] IPv6 ip6tables rule added
[2025-08-06 14:30:15] Summary:
[2025-08-06 14:30:15]   IPv4 addresses in ipset: 114
[2025-08-06 14:30:15]   IPv6 addresses in ipset: 116
[2025-08-06 14:30:15] UptimeRobot whitelisting completed successfully!
```

## Persistence

The script offers to save your firewall rules to survive system reboots. When prompted, choose 'y' to:

- Save ipset rules to `/etc/ipset.conf`
- Save iptables rules to system-specific locations
- Ensure rules are restored automatically on boot

## Security Considerations

- The script only allows **incoming** connections from UptimeRobot IPs
- Uses the `INPUT` chain, maintaining your existing firewall policies
- Employs ipset for efficient IP matching without performance degradation
- Does not modify existing firewall rules beyond adding the UptimeRobot whitelist

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you're running with `sudo`
2. **Command Not Found**: Install ipset and iptables packages
3. **IPv6 Not Supported**: The script handles this gracefully and continues with IPv4

### Verification

Check that rules are active:

```bash
# View IP sets
sudo ipset list uptimerobot.ipv4
sudo ipset list uptimerobot.ipv6

# View iptables rules
sudo iptables -L INPUT -n | grep uptimerobot
sudo ip6tables -L INPUT -n | grep uptimerobot
```

## Updating IP Lists

UptimeRobot occasionally updates their monitoring server IPs. To update:

1. Download the latest IP lists from UptimeRobot
2. Replace the `uptimerobot.ipv4` and `uptimerobot.ipv6` files
3. Re-run the script to update your firewall rules

## Support

For issues, questions, or contributions, please refer to the project repository or documentation.

## License

This project is provided as-is for system administration purposes. Use at your own discretion and ensure compliance with your security policies.