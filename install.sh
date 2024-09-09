#!/bin/bash

set -e

# Root Checker
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo' or log in as root."
    exit 1
fi

# Checking for internet connection
while true; do

    ping -c 1 google.com &>/dev/null &
    ping_pid=$!
    echo -n "Checking host connections: "
    for i in {1..10}; do
        if ps -p $ping_pid >/dev/null; then
            printf ">"
            sleep 0.6
        else
            break
        fi
    done

    wait $ping_pid

    if [ $? -eq 0 ]; then
        echo "Internet: OK!"
        sleep 0.5
        break
    else
        echo "Internet ERR: not connected"
        sleep 0.5
        break
        clear
    fi
done

hijau="\033[32m"
end="\033[0m"

echo ""
echo -e "${hijau} █████╗ ██╗   ██╗████████╗ ██████╗     ██████╗ ███╗   ██╗███████╗${end}"
echo -e "${hijau}██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██╔══██╗████╗  ██║██╔════╝${end}"
echo -e "${hijau}███████║██║   ██║   ██║   ██║   ██║    ██║  ██║██╔██╗ ██║███████${end}"
echo -e "${hijau}██╔══██║██║   ██║   ██║   ██║   ██║    ██║  ██║██║╚██╗██║╚════██║${end}"
echo -e "${hijau}██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██████╔╝██║ ╚████║███████║${end}"
echo -e "${hijau}╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ${end}"
echo -e "${hijau} by EdWArd ${end}"
echo ""

# Check if bind9 service is running
echo "Checking bind9 service"
if ! systemctl is-active --quiet named; then
    echo "bind9 does not exist, installing bind9..."
    apt update
    apt upgrade
    apt install bind9 -y
    echo "bind9 has been successfully installed"
else
    echo "bind9 already exists."
fi

# Backup records & zone files
echo "Backing up files..."
cp /etc/bind/db.127 /etc/bind.127.bak
cp /etc/bind/db.local /etc/bind/local.bak
cp /etc/bind/named.conf.default-zones /etc/bind/named.conf.default-zones.bak

# Get domain name from user
read -p "Enter your domain (e.g., example.com, example.id, example.io): " domain

# Set forward zone file name
forward="/etc/bind/db.${domain}"

# Get first octet of IP address
read -p "First octet of your IP address: " first_octet
reverse="/etc/bind/db.${first_octet}"

sleep 1

# Get IP address from user
read -p "Enter your IP address: " ip_add
echo "Creating configuration"
octets=(${ip_add//./ })

# Remove the fourth octet
octets=("${octets[0]}" "${octets[1]}" "${octets[2]}")

# Reverse the order of octets
reversed_octets=("${octets[2]}" "${octets[1]}" "${octets[0]}")

# Join the reversed octets with dots
reversed_ip="${reversed_octets[0]}.${reversed_octets[1]}.${reversed_octets[2]}"

echo "$reversed_ip"

sleep 1

# Configure forward zone file
cp /etc/bind/db.127 /etc/bind/db.$first_octet

cp /etc/bind/db.local ${forward}_temp &&
    sed -i "s/localhost/${domain}/g" ${forward}_temp &&
    sed -i "s/127.0.0.1/${ip_add}/g" ${forward}_temp &&
    sed -i "/AAA/d" ${forward}_temp &&
    mv ${forward}_temp ${forward}

echo "${forward} zone has been successfully configured"

sleep 1

# Configure reverse zone file
cp /etc/bind/db.127 ${reverse}_temp &&
    sed -i "s/localhost/${domain}/g" ${reverse}_temp &&
    mv ${reverse}_temp ${reverse}

echo "${reverse} zone has been successfully configured"

named="/etc/bind/named.conf.default-zones"

cp ${named} ${named}_temp

sed -i "s/localhost/${domain}/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "Error in sed-1"
    else
        echo "sed done"
    fi

sed -i "s/127.in-addr.arpa/${reversed_ip}.in-addr.arpa/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "Error in sed-1"
    else
        echo "sed done"
    fi

sed -i "s/db.local/db.${domain}/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "Error in sed-1"
    else
        echo "sed done"
    fi

sed -i "s/db.127/db.${first_octet}/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "Error in sed-1"
    else
        echo "sed done"
    fi

mv ${named}_temp ${named}

#
echo "Process successfully completed"
sleep 0.5

echo "Restarting bind9 service.."
sleep 0.2

systemctl restart bind9.service