#!/bin/bash

# SubHunt Pro - Automated Recon & Vulnerability Discovery
# Improved version with better performance, URL discovery, and correct vulnerability checks

set -e

# -------------------------
# ANSI Colors
# -------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# -------------------------
# Banner
# -------------------------
display_banner() {
echo -e "${RED}"
echo "   _____       _     _    _             _"
echo "  / ____|     | |   | |  | |           | |"
echo " | (___  _   _| |__ | |__| |_   _ _ __ | |_"
echo "  \___ \| | | | '_ \|  __  | | | | '_ \| __|"
echo "  ____) | |_| | |_) | |  | | |_| | | | | |_"
echo " |_____/ \__,_|_.__/|_|  |_|\__,_|_| |_|\__|"
echo -e "${NC}"

echo -e "${YELLOW} Automated Recon & Vulnerability Hunter ${NC}"
echo -e "${BLUE}------------------------------------------${NC}"
echo -e "Target: ${GREEN}$1${NC}"
echo -e "${BLUE}------------------------------------------${NC}"
echo ""
}

# -------------------------
# Usage check
# -------------------------
if [ "$#" -ne 1 ]; then
echo -e "${RED}Usage: $0 <target-domain>${NC}"
exit 1
fi

domain=$1
output_dir="recon/$domain"

display_banner "$domain"

mkdir -p "$output_dir"

# -------------------------
# Required tools
# -------------------------
tools_required=(
subfinder
amass
httpx
nmap
gf
gau
waybackurls
katana
gowitness
)

missing_tools=()

for tool in "${tools_required[@]}"; do
if ! command -v "$tool" &> /dev/null; then
missing_tools+=("$tool")
fi
done

if [ ${#missing_tools[@]} -gt 0 ]; then
echo -e "${RED}[!] Missing required tools:${NC}"
for tool in "${missing_tools[@]}"; do
echo -e " - $tool"
done
exit 1
fi

# -------------------------
# Logging function
# -------------------------
log() {
echo -e "${BLUE}[+]${NC} $1"
}

# -------------------------
# Subdomain Enumeration
# -------------------------
log "Running subdomain enumeration..."

{
subfinder -d "$domain" -silent -t 50
amass enum -passive -d "$domain" -silent
} | sort -u > "$output_dir/subdomains.txt"

sub_count=$(wc -l < "$output_dir/subdomains.txt")

log "Discovered $sub_count unique subdomains"

# -------------------------
# Live Host Detection
# -------------------------
log "Checking live web services..."

httpx \
-l "$output_dir/subdomains.txt" \
-silent \
-title \
-status-code \
-tech-detect \
-follow-redirects \
-threads 50 \
-o "$output_dir/live_subdomains.txt"

live_count=$(wc -l < "$output_dir/live_subdomains.txt")

log "Found $live_count live hosts"

# Extract host URLs only
cut -d' ' -f1 "$output_dir/live_subdomains.txt" > "$output_dir/live_hosts.txt"

# -------------------------
# URL Collection
# -------------------------
log "Collecting URLs..."

gau "$domain" > "$output_dir/urls.txt"
waybackurls "$domain" >> "$output_dir/urls.txt"

log "Running crawler..."

katana -list "$output_dir/live_hosts.txt" -silent >> "$output_dir/urls.txt"

sort -u "$output_dir/urls.txt" -o "$output_dir/urls.txt"

url_count=$(wc -l < "$output_dir/urls.txt")

log "Collected $url_count URLs"

# -------------------------
# Vulnerability Pattern Detection
# -------------------------
log "Running vulnerability pattern checks..."

patterns=("xss" "sqli" "lfi" "ssrf" "redirect")

for pattern in "${patterns[@]}"; do

cat "$output_dir/urls.txt" | gf "$pattern" > "$output_dir/${pattern}_vulns.txt"

count=$(wc -l < "$output_dir/${pattern}_vulns.txt")

log "Potential ${pattern^^}: $count findings"

done

# -------------------------
# Port Scanning
# -------------------------
log "Running fast port scan on live hosts..."

nmap \
-iL "$output_dir/live_hosts.txt" \
--top-ports 100 \
-T4 \
-oN "$output_dir/ports.txt"

# -------------------------
# Screenshots
# -------------------------
log "Capturing screenshots..."

gowitness file \
-f "$output_dir/live_hosts.txt" \
-P "$output_dir/screenshots" \
--threads 8 \
--timeout 20

# -------------------------
# Final Output
# -------------------------
echo ""
echo -e "${GREEN}Recon completed successfully!${NC}"
echo -e "${YELLOW}Results saved to:${NC} $output_dir"
echo ""

tree "$output_dir"
