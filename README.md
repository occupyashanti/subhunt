# 🔍 SubHunt  
**Automated Subdomain & Vulnerability Reconnaissance Tool**  

### Option 2: ASCII Art Banner
```text
  _____       _    _                 _   
 / ____| _   _| |__| |__   ___  _ __| |_ 
| (___ | | | | '_ \ '_ \ / _ \| '__| __|
 \___ \| |_| | | | | | | (_) | |  | |_ 
 _____) \__,_|_| |_| |_|\___/|_|   \__|
        The Subdomain Hunter

## 🚀 Features  
- **Subdomain Enumeration** (Subfinder + Amass)  
- **Live Host Detection** (HTTPX)  
- **Port Scanning** (Nmap)  
- **Basic Vulnerability Checks** (GF Patterns: XSS, SQLi, LFI, etc.)  
- **Screenshot Capture** (GoWitness)  
- **Shodan Integration** (Optional OSINT lookup)  

## 🛠️ Usage  
```bash
# Clone the repo  
git clone https://github.com/your-username/SubHunt.git  

# Run the tool  
cd SubHunt  
chmod +x recon.sh  
./recon.sh example.com  
