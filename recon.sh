#!/bin/bash

# SubHunt - Automated Subdomain & Vulnerability Hunter
# Fixed version with proper error handling

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner Function
display_banner() {
    echo -e "${RED}"
    echo '  ____       _    _                 _   '
    echo ' / ___| _   _| |__| |__   ___  _ __| |_ '
    echo ' \___ \| | | | '\''_ \ '\''_ \ / _ \| '\''__| __|'
    echo '  ___) | |_| | | | | | | (_) | |  | |_ '
    echo ' |____/ \__,_|_| |_| |_|\___/|_|   \__|'
    echo -e "${NC}"
    echo -e "${YELLOW}        The Subdomain Hunter${NC}"
    echo -e "${BLUE}-------------------------------------${NC}"
    echo -e "Starting reconnaissance against: ${GREEN}$1${NC}"
    echo -e "${BLUE}-------------------------------------${NC}"
    echo ""
}

# Check if domain is provided
if [ "$#" -ne 1 ]; then
    echo -e "${RED}[!] Usage: $0 <target-domain>${NC}"
    exit 1
fi

# Display Banner
display_banner "$1"

domain=$1
output_dir="recon/$domain"
mkdir -p "$output_dir"

# Configuration
tools_required=("subfinder" "amass" "httpx" "nmap" "gf" "gowitness")

# Check for required tools
missing_tools=()
for tool in "${tools_required[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
    echo -e "${RED}[!] Error: Missing required tools:${NC}"
    for tool in "${missing_tools[@]}"; do
        echo -e "${RED}- $tool${NC}"
    done
    exit 1
fi

# Logging function
log() {
    echo -e "${BLUE}[+]${NC} $1"
}

# Main recon process
log "Starting subdomain enumeration..."
{
    subfinder -d "$domain" -silent
    amass enum -passive -d "$domain" -silent
} | sort -u > "$output_dir/subdomains.txt" || {
    echo -e "${RED}[!] Subdomain enumeration failed${NC}"
    exit 1
}

subdomain_count=$(wc -l < "$output_dir/subdomains.txt")
log "Found $subdomain_count unique subdomains"

log "Checking for live subdomains..."
httpx -silent -title -status-code -tech-detect -follow-redirects \
    -l "$output_dir/subdomains.txt" -o "$output_dir/live_subdomains.txt" || {
    echo -e "${RED}[!] Live host detection failed${NC}"
    exit 1
}

live_count=$(wc -l < "$output_dir/live_subdomains.txt")
log "Found $live_count live subdomains"

log "Starting port scanning..."
nmap -iL "$output_dir/subdomains.txt" -T4 --top-ports 1000 -oN "$output_dir/ports.txt" || {
    echo -e "${RED}[!] Port scanning failed${NC}"
    exit 1
}

log "Running basic vulnerability pattern checks..."
gf_patterns=("xss" "sqli" "lfi" "ssrf" "redirect")
for pattern in "${gf_patterns[@]}"; do
    gf "$pattern" "$output_dir/live_subdomains.txt" > "$output_dir/${pattern}_vulns.txt"
    count=$(wc -l < "$output_dir/${pattern}_vulns.txt")
    log "Found $count potential ${pattern^^} vulnerabilities"
done

log "Capturing screenshots..."
gowitness file -f "$output_dir/live_subdomains.txt" -P "$output_dir/screenshots" \
    --delay 5 --timeout 30 --threads 4 || {
    echo -e "${RED}[!] Screenshot capture failed${NC}"
    exit 1
}

echo -e "${GREEN}[+] Reconnaissance completed successfully. Results saved in $output_dir${NC}"
tree "$output_dir"