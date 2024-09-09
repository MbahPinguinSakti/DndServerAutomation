#!/bin/bash

# Receive input IP from user
read -p "Enter an IP address: " ip

# Split the IP into octets
octets=(${ip//./ })

# Remove the fourth octet
octets=("${octets[0]}" "${octets[1]}" "${octets[2]}")

# Reverse the order of the octets
reversed_octets=("${octets[2]}" "${octets[1]}" "${octets[0]}")

# Join the reversed octets with dots
reversed_ip="${reversed_octets[0]}.${reversed_octets[1]}.${reversed_octets[2]}"

# Print the result
echo "Reversed IP: $reversed_ip"

