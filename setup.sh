#!/bin/bash
pip install python-whois
pip install futures
pip install PySocks
sudo apt-get install figlet
chmod +x number.sh
chmod +x email.sh
read -p "Enter ip2location API key:" ip2location
read -p "Enter ipqualityscore API key:" ipquality
read -p "Enter virustotal API key:" virustotal
read -p "Enter numverify API key:" numverify
sed -i "s#XXXX#$virustotal#" urlreport.sh
sed -i "s#YYYY#$ip2location#" ipintel.sh
sed -i "s#ZZZZ#$ipquality#" ipintel.sh
sed -i "s#NNNN#$numverify#" number.sh
chmod +x ipintel.sh
chmod +x urlreport.sh
