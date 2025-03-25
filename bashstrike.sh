#!/bin/bash

# BashStrike - Bash Pentesting Tool

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Banner Function
banner() {
  echo -e "${GREEN}======================================="
  echo -e "            BashStrike                  "
  echo -e "    Your Bash Pentesting Companion      "
  echo -e "=======================================${NC}"
}

# Port Scanning Function
port_scan() {
  echo -e "${GREEN}[+] Starting Port Scan...${NC}"
  read -p "Enter Target IP: " target
  echo -e "${GREEN}1) Scan Common Ports (21,22,23,25,53,80,110,143,443,445,587,993,995,3306,3389)\n2) Scan Custom Port Range\n3) Scan Specific Ports${NC}"
  read -p "Choose an option: " option

  if [ "$option" == "1" ]; then
    ports=(21 22 23 25 53 80 110 143 443 445 587 993 995 3306 3389)
  elif [ "$option" == "2" ]; then
    read -p "Enter Port Range (e.g., 1-1000): " range
    ports=($(seq $(echo $range | cut -d '-' -f 1) $(echo $range | cut -d '-' -f 2)))
  elif [ "$option" == "3" ]; then
    read -p "Enter Specific Ports (comma-separated, e.g., 22,80,443): " port_input
    IFS=',' read -r -a ports <<< "$port_input"
  else
    echo -e "${RED}[-] Invalid Option!${NC}"
    return
  fi

  echo -e "${GREEN}[+] Scanning $target...${NC}"

  for port in "${ports[@]}"; do
    (echo >/dev/tcp/$target/$port) &>/dev/null && \
    echo -e "${GREEN}Port $port - OPEN${NC}" || \
    echo -e "${YELLOW}Port $port - CLOSED${NC}" &
  done
  wait
  echo -e "${GREEN}[+] Scan Complete!${NC}"
}

# Network Mapping Function
network_map() {
  echo -e "${GREEN}[+] Mapping Network...${NC}"
  read -p "Enter Network Range (e.g., 192.168.1.0/24): " range
  nmap -sn $range | grep "Nmap scan report for" | awk '{print $5}'
}

# Subdomain Enumeration Function
subdomain_enum() {
  echo -e "${GREEN}[+] Starting Subdomain Enumeration...${NC}"
  read -p "Enter Target Domain: " domain
  read -p "Enter Wordlist Path: " wordlist

  for sub in $(cat $wordlist); do
    host "$sub.$domain" &>/dev/null && \
    echo -e "${GREEN}[+] Found: $sub.$domain${NC}"
  done
}

# Brute Force Function (SSH)
brute_force_ssh() {
  echo -e "${GREEN}[+] Starting SSH Brute Force...${NC}"
  read -p "Enter Target IP: " target
  read -p "Enter Username: " username
  read -p "Enter Password List Path: " passlist

  for pass in $(cat $passlist); do
    sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $username@$target exit 2>/dev/null && \
    echo -e "${GREEN}[+] Password Found: $pass${NC}" && exit
    echo -e "${RED}[-] Tried: $pass${NC}"
  done
}

# Packet Capture Function
packet_capture() {
  echo -e "${GREEN}[+] Starting Packet Capture...${NC}"
  read -p "Enter Network Interface (e.g., eth0): " interface
  read -p "Enter Output File Name: " filename
  sudo tcpdump -i $interface -w $filename
}

# Main Menu Function
main_menu() {
  banner
  echo -e "${GREEN}Select an option:${NC}"
  echo "1) Port Scan"
  echo "2) Network Mapping"
  echo "3) Subdomain Enumeration"
  echo "4) SSH Brute Force"
  echo "5) Packet Capture"
  echo "6) Exit"

  read -p "Enter your choice: " choice

  case $choice in
    1) port_scan ;;
    2) network_map ;;
    3) subdomain_enum ;;
    4) brute_force_ssh ;;
    5) packet_capture ;;
    6) exit 0 ;;
    *) echo -e "${RED}Invalid Option!${NC}" ;;
  esac
}

# Run the Main Menu
while true; do
  main_menu
done
