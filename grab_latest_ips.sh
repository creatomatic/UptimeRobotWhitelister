# Configuration
DEFAULT_URL="https://cdn.uptimerobot.com/api/IPv4andIPv6.txt"
OUTPUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IPV4_FILE="$OUTPUT_DIR/uptimerobot.ipv4"
IPV6_FILE="$OUTPUT_DIR/uptimerobot.ipv6"
TEMP_FILE="/tmp/uptimerobot_ips_temp.txt"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [URL]"
    echo "  URL: Optional URL to download IP addresses from"
    echo "       Default: $DEFAULT_URL"
    echo ""
    echo "Examples:"
    echo "  $0"
    echo "  $0 https://example.com/ips.txt"
    exit 1
}

# Function to validate IP address
is_valid_ipv4() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        local IFS='.'
        local -a parts=($ip)
        for part in "${parts[@]}"; do
            if (( part > 255 )); then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

is_valid_ipv6() {
    local ip=$1
    # Basic IPv6 validation - contains colons and valid hex characters
    if [[ $ip =~ ^[0-9a-fA-F:]+$ ]] && [[ $ip == *:* ]]; then
        return 0
    fi
    return 1
}

# Parse command line arguments
URL="${1:-$DEFAULT_URL}"

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
fi

log_message "Starting IP address download and split process..."
log_message "Source URL: $URL"
log_message "Output directory: $OUTPUT_DIR"

# Check if required tools are available
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    log_message "Error: Neither curl nor wget is available. Please install one of them."
    exit 1
fi

# Download the file
log_message "Downloading IP addresses..."
if command -v curl >/dev/null 2>&1; then
    if ! curl -s -f -o "$TEMP_FILE" "$URL"; then
        log_message "Error: Failed to download from $URL using curl"
        exit 1
    fi
elif command -v wget >/dev/null 2>&1; then
    if ! wget -q -O "$TEMP_FILE" "$URL"; then
        log_message "Error: Failed to download from $URL using wget"
        exit 1
    fi
fi

# Check if download was successful
if [[ ! -f "$TEMP_FILE" ]] || [[ ! -s "$TEMP_FILE" ]]; then
    log_message "Error: Downloaded file is empty or doesn't exist"
    exit 1
fi

log_message "Download completed successfully"

# Initialize output files
> "$IPV4_FILE"
> "$IPV6_FILE"

# Process the downloaded file
log_message "Processing and splitting IP addresses..."

ipv4_count=0
ipv6_count=0
invalid_count=0

while IFS= read -r line; do
    # Skip empty lines and comments
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    # Remove leading/trailing whitespace
    ip=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Skip empty lines after trimming
    if [[ -z "$ip" ]]; then
        continue
    fi
    
    # Check if it's a valid IPv4 address
    if is_valid_ipv4 "$ip"; then
        echo "$ip" >> "$IPV4_FILE"
        ((ipv4_count++))
    # Check if it's a valid IPv6 address
    elif is_valid_ipv6 "$ip"; then
        echo "$ip" >> "$IPV6_FILE"
        ((ipv6_count++))
    else
        log_message "Warning: Invalid IP address format: $ip"
        ((invalid_count++))
    fi
done < "$TEMP_FILE"

# Clean up temporary file
rm -f "$TEMP_FILE"

# Report results
log_message "Processing completed successfully!"
log_message "Results:"
log_message "  IPv4 addresses: $ipv4_count (saved to: $IPV4_FILE)"
log_message "  IPv6 addresses: $ipv6_count (saved to: $IPV6_FILE)"

if [[ $invalid_count -gt 0 ]]; then
    log_message "  Invalid addresses skipped: $invalid_count"
fi

# Show file sizes
if [[ -f "$IPV4_FILE" ]]; then
    ipv4_size=$(wc -l < "$IPV4_FILE" | tr -d ' ')
    log_message "  IPv4 file contains $ipv4_size lines"
fi

if [[ -f "$IPV6_FILE" ]]; then
    ipv6_size=$(wc -l < "$IPV6_FILE" | tr -d ' ')
    log_message "  IPv6 file contains $ipv6_size lines"
fi

log_message "IP address grab and split completed successfully!"

# Optional: Show first few entries from each file
if [[ $ipv4_count -gt 0 ]]; then
    log_message "Sample IPv4 addresses:"
    head -3 "$IPV4_FILE" | while read -r ip; do
        log_message "  $ip"
    done
fi

if [[ $ipv6_count -gt 0 ]]; then
    log_message "Sample IPv6 addresses:"
    head -3 "$IPV6_FILE" | while read -r ip; do
        log_message "  $ip"
    done
fi