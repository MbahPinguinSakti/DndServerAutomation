#!/bin/bash

set -e
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
        clear
    fi
done

hijau="\033[32m"
end="\033[0m"

echo ""
echo -e "${hijau} █████╗ ██╗   ██╗████████╗ ██████╗     ██████╗ ███╗   ██╗███████╗${end}"
echo -e "${hijau}██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗    ██╔══██╗████╗  ██║██╔════╝${end}"
echo -e "${hijau}███████║██║   ██║   ██║   ██║   ██║    ██║  ██║██╔██╗ ██║███████${end}"
echo -e "${hijau}██╔══██║██║   ██║   ██║   ██║   ██║    ██║  ██║██║╚██╗██║╚════██║${end}"
echo -e "${hijau}██║  ██║╚██████╔╝   ██║   ╚██████╔╝    ██████╔╝██║ ╚████║███████║${end}"
echo -e "${hijau}╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ${end}"
echo -e "by EdWArd"
echo ""

# Pisahkan IP menjadi oktet

echo "cheking bind9 service"
#cheking bind9.service
if ! systemctl is-active --quiet named; then
    echo "bind9 tidak aktif, sedang menginstal bind9..."
    # apt update
    # apt upgrade
    apt install bind9 -y
    echo "bind9 telah berhasil diinstal."
else
    echo "bind9 sudah aktif."
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
reverse="/etc/bind/db.${first_octet}"

sleep 1

#asking for ip address
read -p "enter your ip address: " ip_add
echo "creating configuration"
octets=(${ip_add//./ })
# Hapus oktet keempat
octets=("${octets[0]}" "${octets[1]}" "${octets[2]}")
# Balikkan urutan oktet
reversed_octets=("${octets[2]}" "${octets[1]}" "${octets[0]}")
# Gabungkan oktet yang dibalik dengan titik
reversed_ip="${reversed_octets[0]}.${reversed_octets[1]}.${reversed_octets[2]}"

echo "$reversed_ip"

sleep 1

#manip records forwardZ file
cp /etc/bind/db.127 /etc/bind/db.$first_octet

#copy forward file into forwardfile_temp
cp /etc/bind/db.local ${forward}_temp &&
    sed -i "s/localhost/${domain}/g" ${forward}_temp &&
    sed -i "s/127.0.0.1/${ip_add}/g" ${forward}_temp &&
    sed -i "/AAA/d" ${forward}_temp &&
    mv ${forward}_temp ${forward}

echo "${forward} zone has been sucess fully configured"

sleep 1

cp /etc/bind/db.127 ${reverse}_temp &&
    sed -i "s/localhost/${domain}/g" ${reverse}_temp &&
    mv ${reverse}_temp ${reverse}

echo "${reverse} zone has been sucess fully configured"

named="/etc/bind/named.conf.default-zones"

cp ${named} ${named}_temp
 
sed -i "s/localhost/${domain}/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "error di sed-1"
    else
        echo "sed done "
    fi

sed -i "s/127.in-addr.arpa/${reversed_ip}.in-addr.arpa/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "error di sed-1"
    else
        echo "sed done "
    fi

sed -i "s/db.local/db.${domain}/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "error di sed-1"
    else
        echo "sed done "
    fi

sed -i "s/db.127/db.${first_octet}/g" "${named}_temp"
    if [ $? -ne 0 ]; then
        echo "error di sed-1"
    else
        echo "sed done "
    fi

mv ${named}_temp ${named}

#
echo "process sucessfully"
