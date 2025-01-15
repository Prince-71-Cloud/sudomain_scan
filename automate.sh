#!/bin/bash

# Prompt the user to enter the domain name
read -p "Enter the domain name: " domain

# Create directories
sudo mkdir /Path_to_the_folder/$domain
sudo mkdir /Path_to_the_folder/$domain/xray
sudo chmod 777 /Path_to_the_folder/$domain/*

# Run subdomain enumeration tools
subfinder -d $domain -all -silent |sudo anew Path_to_the_folder/$domain/subs.txt
assetfinder -subs-only $domain |sudo anew /Path_to_the_folder/$domain/subs.txt
sublist3r -d $domain | sudo anew /Path_to_the_folder/$domain/subs.txt
chaos -d $domain -silent | sudo anew /Path_to_the_folder/$domain/subs.txt
github-subdomains -d $domain -raw | sudo anew /Path_to_the_folder/$domain/subs.txt
findomain -t $domain --external-subdomains | sudo anew /Path_to_the_folder/$domain/subs.txt

#Amass subdomain enumerations
amass enum -active -d $domain -p 80,443,8080 | sudo anew /Path_to_the_folder/$domain/amass.txt

#findomain subdomain enumerations
findomain -t $domain -p 80,443,8080 | sudo anew /Path_to_the_folder/$domain/findomain.txt
findomain -f /Path_to_the_folder/$domain/findomain.txt -p 80,443,8080 | sudo anew /Path_to_the_folder/$domain/findomain.txt

# Create for sub-subdomains
subfinder -dL /Path_to_the_folder/$domain/subs.txt -all -silent |sudo anew /Path_to_the_folder/$domain/subs.txt

# Check for alive subdomains
cat /Path_to_the_folder/$domain/subs.txt | httpx -silent |sudo anew /Path_to_the_folder/$domain/alive.txt

# Test by Xray
for i in $(cat /Path_to_the_folder/$domain/alive.txt); do
    xray_linux_amd64 ws --basic-crawler $i --plugins xss,sqldet,xxe,ssrf,cmd-injection,path-traversal --ho $(date +"%T")
done

# Test for nuclei
cat /Path_to_the_folder/$domain/alive.txt |sudo nuclei -t Path_to_the_folder/cent-nuclei-templates -es info,unknown -etags ssl,network |sudo anew /Path_to_the_folder/$domain/nuclei.txt
