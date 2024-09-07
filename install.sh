#!/bin/bash

# Root Checker
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo' or log in as root."
    exit 1
fi

#cheking for internet
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
        echo "internet: OK!"
        sleep 0.5
        break
    else
        echo "internet ERR: not connected"
        sleep 0.5
        break
        # exit 1
    fi
done

echo "cheking bind9 service"
#cheking bind9.service
if [ ! -f /lib/systemd/system/named.service; ]; then
    echo "bind9 doesnt exist, installing bind9"
    apt update
    apt upgrade
    apt install bind9 -y
else
    echo "bind9 exist, skip.."
fi

#backup file records & zone
echo "backup file..."
cp /etc/bind/db.127 /etc/bind.127.bak
cp /etc/bind/db.local /etc/bind/local.bak
cp /etc/bind/named.conf.default-zones /etc/bind/named.conf.default-zones.bak

#change name of forward zone file
read -p "enter your domain (e.g example.com, example.id, example.io): " domain

#name for forward file
forward="/etc/bind/db.${domain}"

#change name reverse zone file
read -p "first octet of your ip address: " first_octet

#asking for ip address
read -p "enter your ip address: " ip_add
echo "creating configuration"

#manip records forwardZ file
cp /etc/bind/db.127 /etc/bind/db.$first_octet 

#copy forward file into forwardfile_temp
cp /etc/bind/db.local ${forward}_temp && \ sed -i 's/localhost/${domain}/g; s/127.0.0.1/${ip_add}g' ${forward}_temp && \ mv ${forward}_temp ${forward}