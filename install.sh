#!/bin/bash

# Root Checker
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo' or log in as root."
    exit 1
fi

#banner

# Disable shell interpretation of special characters
cat << "EOF"
:::::::-.  :::.    :::. .::::::.  .::::::..,:::::: :::::::.. :::      .::..,:::::: :::::::..    :::.      ...    :::::::::::::::   ...     
 ;;,   `';,`;;;;,  `;;;;;;`    ` ;;;`    `;;;;'''' ;;;;``;;;;';;,   ,;;;' ;;;;'''' ;;;;``;;;;   ;;`;;     ;;     ;;;;;;;;;;;''''.;;;;;;;.  
 `[[     [[  [[[[[. '[['[==/[[[[,'[==/[[[[,[[cccc   [[[,/[[[' \[[  .[[/    [[cccc   [[[,/[[['  ,[[ '[[,  [['     [[[     [[    ,[[     \[[,
  $$,    $$  $$$ "Y$c$$  '''    $  '''    $$$""""   $$$$$$c    Y$c.$$"     $$""""   $$$$$$c   c$$$cc$$$c $$      $$$     $$    $$$,     $$$
  888_,o8P'  888    Y88 88b    dP 88b    dP888oo,__ 888b "88bo, Y88P       888oo,__ 888b "88bo,888   888,88    .d888     88,   "888,_ _,88P
  MMMMP"`    MMM     YM  "YMmMY"   "YMmMY" """"YUMMMMMMM   "W"   MP        """"YUMMMMMMM   "W" YMM   ""`  "YmmMMMM""     MMM     "YMMMMMP"         
EOF

#cheking for internet
while true; do

    ping -c 1 google.com &>/dev/null &
    ping_pid=$!
    echo -n "Checking host connections: "
    for i in {1..10}; do
        # Periksa apakah proses ping masih berjalan
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
        exit 1
    fi
done

echo "cheking bind9 service" #cheking bind9.service
if [ ! -f /lib/systemd/system/bind9.service ]; then
    echo "bind9 doesnt exist, installing bind9"
    sudo apt update
    sudo apt upgrade
    sudo apt install bind9 -y
else
    echo "bind9 exist"
fi

#backup file records & zone
echo "backup file..."
cp /etc/bind/db.127 /etc/bind.127.bak
cp /etc/bind/db.local /etc/bind/local.bak
cp /etc/bind/named.conf.default-zones /etc/bind/named.conf.default-zones.bak

#change name of forward zone file
read -p " domain ?(e.g example.com, example.id, example.io): " domain
mv /etc/bind/db.local /etc/bind/db.$domain
forward="/etc/bind/db.${domain}"

#change name reverse zone file
read -p "first octet of your ip address: " first_oktet
mv /etc/bind/db.127 /etc/bind/db.$first_oktet

#asking for ip address
read -p "enter your ip address: " ip_Add

#manip records forwardZ file
new_soa="ns1.${domain}."
new_soa_root="root.${domain}."

temp=$(mktemp)

while IFS= read -r line; do
    if [[ "$line" == *"SOA localhost. root.localhost."* ]]; then
        echo "@     IN    SOA   ${new_soa} ${new_soa_root} (" >>"$temp"
        echo "              2023091501  ; Serial" >>"$temp" # Serial number contoh
        echo "              3600        ; Refresh" >>"$temp"
        echo "              1800        ; Retry" >>"$temp"
        echo "              1209600     ; Expire" >>"$temp"
        echo "              86400 )     ; Minimum TTL" >>"$temp"

    elif [[ "$line" == *"@  IN AS 127.0.0.1"* ]]; then
        echo "ns1.${domain}  IN  A  ${ip_add}" >>"$temp"

    else
        echo "$line" >>"$temp"  

    fi

done <"$forward"
