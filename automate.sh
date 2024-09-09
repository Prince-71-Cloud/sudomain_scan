#!/bin/bash

# Prompt the user to enter the domain name
read -p "Enter the domain name: " domain

# Create directories
sudo mkdir /home/aman/Documents/Pentest/$domain
sudo mkdir /home/aman/Documents/Pentest/$domain/xray
sudo chmod 777 /home/aman/Documents/Pentest/$domain/*

# Run subdomain enumeration tools
subfinder -d $domain -all -silent |sudo anew /home/aman/Documents/Pentest/$domain/subs.txt
assetfinder -subs-only $domain |sudo anew /home/aman/Documents/Pentest/$domain/subs.txt
sublist3r -d $domain | sudo anew /home/aman/Documents/Pentest/$domain/subs.txt
chaos -d $domain -silent | sudo anew /home/aman/Documents/Pentest/$domain/subs.txt
github-subdomains -d $domain -raw | sudo anew /home/aman/Documents/Pentest/$domain/subs.txt
findomain -t $domain --external-subdomains | sudo anew /home/aman/Documents/Pentest/$domain/subs.txt

#Amass subdomain enumerations
amass enum -active -d $domain -p 80,443,8080 | sudo anew /home/aman/Documents/Pentest/$domain/amass.txt

#findomain subdomain enumerations
findomain -t $domain -p 80,443,8080 | sudo anew /home/aman/Documents/Pentest/$domain/findomain.txt
findomain -f /home/aman/Documents/Pentest/$domain/findomain.txt -p 80,443,8080 | sudo anew /home/aman/Documents/Pentest/$domain/findomain.txt

# Create for sub-subdomains
subfinder -dL /home/aman/Documents/Pentest/$domain/subs.txt -all -silent |sudo anew /home/aman/Documents/Pentest/$domain/subs.txt

# Check for alive subdomains
cat /home/aman/Documents/Pentest/$domain/subs.txt | httpx -silent |sudo anew /home/aman/Documents/Pentest/$domain/alive.txt

# Test by Xray
for i in $(cat /home/aman/Documents/Pentest/$domain/alive.txt); do
    xray_linux_amd64 ws --basic-crawler $i --plugins xss,sqldet,xxe,ssrf,cmd-injection,path-traversal --ho $(date +"%T")
done

# Test for nuclei
cat /home/aman/Documents/Pentest/$domain/alive.txt |sudo nuclei -t /home/aman/cent-nuclei-templates -es info,unknown -etags ssl,network |sudo anew /home/aman/Documents/Pentest/$domain/nuclei.txt
