
# SubHunt  
### **Automated Subdomain & Vulnerability Reconnaissance Tool**  

```text
  _____       _    _                 _   
 / ____| _   _| |__| |__   ___  _ __| |_ 
| (___ | | | | '_ \ '_ \ / _ \| '__| __|
 \___ \| |_| | | | | | | (_) | |  | |_ 
 _____) \__,_|_| |_| |_|\___/|_|   \__|
        The Subdomain Hunter
```

A powerful **offensive reconnaissance** tool that automates subdomain discovery, live host detection, port scanning, and basic vulnerability checks for bug bounty hunters and penetration testers.  

---

## **Features**  
✔ **Subdomain Enumeration** – Combines [Subfinder](https://github.com/projectdiscovery/subfinder) & [Amass](https://github.com/OWASP/Amass) for maximum coverage.  
✔ **Live Host Detection** – Uses [HTTPX](https://github.com/projectdiscovery/httpx) to filter active web services.  
✔ **Port Scanning** – Lightweight [Nmap](https://nmap.org) scans for open ports.  
✔ **Vulnerability Checks** – Basic [GF Patterns](https://github.com/tomnomnom/gf) (XSS, SQLi, LFI, etc.).  
✔ **Screenshot Capture** – [GoWitness](https://github.com/sensepost/gowitness) for visual recon.  
✔ **Shodan Integration** – Optional OSINT lookups for exposed services.  

---

## **Quick Start**  

### **Installation**  
```bash
git clone https://github.com/your-username/SubHunt.git  
cd SubHunt  
chmod +x recon.sh  
```

### **Usage**  
```bash
./recon.sh example.com  
```

### **Options**  
| Flag | Description | Example |
|------|-------------|---------|
| `-o` | Output directory | `./recon.sh -o ~/reports example.com` |
| `-s` | Shodan scan | `./recon.sh -s example.com` |
| `-f` | Target list (file) | `./recon.sh -f targets.txt` |

---

##  **Output Structure**  
```text
SubHunt/
├── scans/
│   ├── subdomains.txt      # Found subdomains  
│   ├── live_hosts.txt      # Active HTTP(S) hosts  
│   ├── nmap_scans/         # Nmap results  
│   ├── screenshots/        # GoWitness captures  
│   └── vulnerabilities/   # GF pattern matches  
└── logs/                  # Tool execution logs  
```

---

## 🔧 **Dependencies**  
- **Required**:  
  ```bash
  # Install tools (Debian/Ubuntu)  
  sudo apt install -y nmap subfinder amass httpx  
  go install github.com/sensepost/gowitness@latest  
  ```
- **Optional**:  
  - Shodan CLI (`pip install shodan`)  

---

##  **License**  
MIT © [occupyashanti](https://github.com/occupyashanti)  

---

### **Why Use SubHunt?**  
- **Fast & Lightweight** – No bloated dependencies.  
- **Modular** – Easily extend with new tools.  
- **Bug Bounty Ready** – Perfect for initial recon.  

**Happy Hunting!**  

---

