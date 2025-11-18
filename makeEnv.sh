#!/bin/bash

# Impacket-Jump - Python Environment Setup Script
# https://github.com/MaorSabag/impacket-jump

set -e  # Exit on error

VENV_DIR=".venv"
REPO_URL="https://github.com/MaorSabag/impacket-jump.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  Impacket-Jump - Environment Setup${NC}"
echo -e "${CYAN}================================================${NC}\n"

# Check if Python 3.10+ is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}[!] Python 3 is not installed!${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}')
MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

echo -e "${GREEN}[+] Found: Python $PYTHON_VERSION${NC}"

if [ "$MAJOR" -lt 3 ] || ([ "$MAJOR" -eq 3 ] && [ "$MINOR" -lt 10 ]); then
    echo -e "${RED}[!] Python 3.10+ is required!${NC}"
    echo -e "${YELLOW}[*] Current version: $PYTHON_VERSION${NC}"
    exit 1
fi

# Check if virtual environment already exists
if [ -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}[*] Virtual environment already exists${NC}"
    read -p "Recreate virtual environment? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}[*] Removing old virtual environment...${NC}"
        rm -rf "$VENV_DIR"
    else
        echo -e "${GREEN}[+] Using existing virtual environment${NC}"
        source "$VENV_DIR/bin/activate"
        echo -e "${GREEN}[+] Virtual environment activated!${NC}"
        echo -e "${BLUE}[*] Python: $(which python)${NC}"
        
        echo -e "\n${CYAN}================================================${NC}"
        echo -e "${GREEN}[+] Setup complete!${NC}"
        echo -e "${CYAN}================================================${NC}\n"

        exec $SHELL
    fi
fi

# Create virtual environment
echo -e "${YELLOW}[*] Creating virtual environment (.venv)...${NC}"
python3 -m venv "$VENV_DIR"

if [ ! -d "$VENV_DIR" ]; then
    echo -e "${RED}[!] Failed to create virtual environment${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Virtual environment created successfully${NC}"

# Activate virtual environment
echo -e "${YELLOW}[*] Activating virtual environment...${NC}"
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo -e "${YELLOW}[*] Upgrading pip...${NC}"
pip install --upgrade pip > /dev/null 2>&1

# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo -e "${YELLOW}[*] Installing dependencies from requirements.txt...${NC}"
    pip install -r requirements.txt
else
    echo -e "${YELLOW}[*] requirements.txt not found, installing Impacket manually...${NC}"
    pip install impacket
fi

echo -e "${GREEN}[+] All dependencies installed successfully!${NC}"

# Show installed packages
echo -e "\n${BLUE}[*] Installed packages:${NC}"
pip list | grep -i impacket

echo -e "\n${CYAN}================================================${NC}"
echo -e "${GREEN}[+] Setup complete!${NC}"
echo -e "${CYAN}================================================${NC}\n"

echo -e "${YELLOW}[*] Virtual environment is now active${NC}"
echo -e "${BLUE}[*] Python: $(which python)${NC}"
echo -e "${BLUE}[*] Location: $(pwd)${NC}\n"

echo -e "${YELLOW}To activate this environment in the future:${NC}"
echo -e "  ${GREEN}cd impacket-jump${NC}"
echo -e "  ${GREEN}source .venv/bin/activate${NC}\n"

echo -e "${YELLOW}To deactivate:${NC}"
echo -e "  ${GREEN}deactivate${NC}\n"

echo -e "${CYAN}Usage Examples:${NC}"
echo -e "${GREEN}# Create service (upload binary)${NC}"
echo -e "python impacket-jump.py DOMAIN/user:'Passw0rd!'@10.0.0.15 -file payload.exe -service-name JumpSvc -service-display-name \"Jump Loader\" -service-description \"Managed via Impacket\" -share-path \"C\$\\\\Program Files\\\\Custom\" -create\n"

echo -e "${GREEN}# Start service${NC}"
echo -e "python impacket-jump.py DOMAIN/user:'Passw0rd!'@10.0.0.15 -service-name JumpSvc -start\n"

echo -e "${CYAN}Available Actions:${NC}"
echo -e "  ${BLUE}-create${NC}       Upload and create service"
echo -e "  ${BLUE}-start${NC}        Start existing service"
echo -e "  ${BLUE}-stop${NC}         Stop running service"
echo -e "  ${BLUE}-delete${NC}       Delete service"
echo -e "  ${BLUE}-cleanup${NC}      Delete service and remove binary"
echo -e "  ${BLUE}-info${NC}         Get service information"
echo -e "  ${BLUE}-change-info${NC}  Modify service metadata\n"

# Keep shell in virtual environment
exec $SHELL
