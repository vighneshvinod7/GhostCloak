#!/bin/bash

# Function to check if Windscribe is connected
check_vpn_status() {
    VPN_STATUS=$(windscribe-cli status | grep -i "Connected")
    if [[ -z "$VPN_STATUS" ]]; then
        return 1  # VPN not connected
    else
        return 0  # VPN connected
    fi
}

# Randomize MAC address
echo "Randomizing MAC address..."
sudo macchanger -r eth0

# Disconnect from any previous Windscribe VPN connection
echo "Disconnecting from any previous Windscribe VPN connection..."
windscribe-cli disconnect
sleep 2

# Get a list of available Windscribe locations and pick a random one
echo "Fetching list of available Windscribe locations..."
RANDOM_SERVER=$(windscribe-cli locations | shuf -n 1 | awk '{print $1}')
echo "Connecting to server: $RANDOM_SERVER"
windscribe-cli connect "$RANDOM_SERVER" &

# Wait for VPN to connect
sleep 5

# Verify if the VPN connection was successful
check_vpn_status
if [[ $? -eq 0 ]]; then
    echo "VPN connected to $RANDOM_SERVER. Enabling VPN-only traffic..."

    # Allow traffic only through the VPN interface (usually tun0)
    sudo iptables -A OUTPUT -o utun420 -j ACCEPT
    sudo iptables -A INPUT -i utun420 -j ACCEPT
    sudo iptables -A OUTPUT -j REJECT
    sudo iptables -A INPUT -j REJECT
else
    echo "VPN failed to connect. Blocking all internet traffic."
    sudo iptables -A OUTPUT -j REJECT
    sudo iptables -A INPUT -j REJECT
    exit 1
fi

# Watchdog to monitor VPN connection
while true; do
    check_vpn_status
    if [[ $? -eq 0 ]]; then
        echo "VPN is still connected."
    else
        echo "VPN disconnected. Trying to reconnect..."
        windscribe-cli disconnect
        sleep 2
        RANDOM_SERVER=$(windscribe-cli locations | shuf -n 1 | awk '{print $1}')
        windscribe-cli connect "$RANDOM_SERVER"
        sleep 10  # Give it time to reconnect
    fi
    sleep 120  # Check every 2 minutes
done
