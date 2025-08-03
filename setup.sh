#!/bin/bash

echo "📦 Installing GhostCloak..."

# Ensure required tools are installed
echo "🔍 Checking dependencies..."
for cmd in windscribe-cli macchanger iptables; do
    if ! command -v $cmd &>/dev/null; then
        echo "❌ $cmd not found. Please install it manually."
        exit 1
    fi
done

# Copy scripts
echo "📁 Copying scripts..."
chmod +x ghostcloak.sh antighost.sh
cp ghostcloak.sh /usr/local/bin/ghostcloak
cp antighost.sh /usr/local/bin/antighost

# Set up desktop launchers (optional)
echo "🖥️ Setting up desktop launchers..."
mkdir -p ~/.local/share/applications
cp GhostCloak.desktop AntiGhost.desktop ~/.local/share/applications/
cp ghostcloak.ico antighost.ico ~/.local/share/icons/

chmod +x ~/.local/share/applications/*.desktop

echo "✅ Setup complete. You can now run 'ghostcloak' or use the desktop icons."
