#!/bin/bash

# Reset firewall rules
echo "Resetting firewall rules..."
sudo iptables -F

# Revert MAC address to original (replace with your real MAC address)
echo "Restoring original MAC address..."
sudo macchanger -m YOUR-MAC eth0

# Disconnect from Windscribe VPN
echo "Disconnecting from Windscribe VPN..."
sudo windscribe-cli disconnect
