#!/bin/bash

# UptimeRobot Whitelister Script
# This script creates ipsets for UptimeRobot IPv4 and IPv6 addresses
# and configures iptables to accept connections from these addresses

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_message "Starting UptimeRobot whitelisting process..."

# Create IPv4 ipset
log_message "Creating IPv4 ipset: uptimerobot.ipv4"
if ipset list uptimerobot.ipv4 >/dev/null 2>&1; then
    log_message "IPv4 ipset already exists, flushing it"
    ipset flush uptimerobot.ipv4
else
    ipset create uptimerobot.ipv4 hash:ip family inet
fi

# Create IPv6 ipset
log_message "Creating IPv6 ipset: uptimerobot.ipv6"
if ipset list uptimerobot.ipv6 >/dev/null 2>&1; then
    log_message "IPv6 ipset already exists, flushing it"
    ipset flush uptimerobot.ipv6
else
    ipset create uptimerobot.ipv6 hash:ip family inet6
fi

# Add IPv4 addresses to ipset
log_message "Adding IPv4 addresses to ipset"
if [ -f "$SCRIPT_DIR/uptimerobot.ipv4" ]; then
    while IFS= read -r ip; do
        if [ -n "$ip" ] && [[ ! "$ip" =~ ^#.* ]]; then
            ipset add uptimerobot.ipv4 "$ip" 2>/dev/null || log_message "Warning: Failed to add IPv4 address $ip"
        fi
    done < "$SCRIPT_DIR/uptimerobot.ipv4"
    log_message "IPv4 addresses added successfully"
else
    log_message "Warning: uptimerobot.ipv4 file not found in $SCRIPT_DIR"
fi

# Add IPv6 addresses to ipset
log_message "Adding IPv6 addresses to ipset"
if [ -f "$SCRIPT_DIR/uptimerobot.ipv6" ]; then
    while IFS= read -r ip; do
        if [ -n "$ip" ] && [[ ! "$ip" =~ ^#.* ]]; then
            ipset add uptimerobot.ipv6 "$ip" 2>/dev/null || log_message "Warning: Failed to add IPv6 address $ip"
        fi
    done < "$SCRIPT_DIR/uptimerobot.ipv6"
    log_message "IPv6 addresses added successfully"
else
    log_message "Warning: uptimerobot.ipv6 file not found in $SCRIPT_DIR"
fi

# Add iptables rules for IPv4
log_message "Configuring iptables rules for IPv4"
if ! iptables -C INPUT -m set --match-set uptimerobot.ipv4 src -j ACCEPT 2>/dev/null; then
    iptables -I INPUT -m set --match-set uptimerobot.ipv4 src -j ACCEPT
    log_message "IPv4 iptables rule added"
else
    log_message "IPv4 iptables rule already exists"
fi

# Add ip6tables rules for IPv6
log_message "Configuring ip6tables rules for IPv6"
if ! ip6tables -C INPUT -m set --match-set uptimerobot.ipv6 src -j ACCEPT 2>/dev/null; then
    ip6tables -I INPUT -m set --match-set uptimerobot.ipv6 src -j ACCEPT
    log_message "IPv6 ip6tables rule added"
else
    log_message "IPv6 ip6tables rule already exists"
fi

# Display summary
log_message "Summary:"
ipv4_count=$(ipset list uptimerobot.ipv4 | grep -c "^[0-9]" || echo "0")
ipv6_count=$(ipset list uptimerobot.ipv6 | grep -c "^[0-9a-f:]" || echo "0")
log_message "  IPv4 addresses in ipset: $ipv4_count"
log_message "  IPv6 addresses in ipset: $ipv6_count"
log_message "UptimeRobot whitelisting completed successfully!"

# Optional: Save ipset rules to survive reboot
read -p "Do you want to save ipset rules to survive reboots? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_message "Saving ipset rules..."
    if command -v ipset save >/dev/null 2>&1; then
        ipset save > /etc/ipset.conf
        log_message "ipset rules saved to /etc/ipset.conf"
    else
        log_message "Warning: ipset-save command not found. Rules may not persist after reboot."
    fi
    
    # Save iptables rules
    if command -v iptables-save >/dev/null 2>&1; then
        iptables-save > /etc/sysconfig/iptables 2>/dev/null || log_message "Warning: Could not save iptables rules"
        ip6tables-save > /etc/sysconfig/ip6tables 2>/dev/null || log_message "Warning: Could not save ip6tables rules"
        log_message "iptables rules saved"
    fi
fi

log_message "Script execution completed."