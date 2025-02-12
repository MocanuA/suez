#!/bin/bash

# Variables
ZABBIX_SERVER="193.70.2.61"
ZABBIX_AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
ZABBIX_RELEASE_PKG="zabbix-release_6.0-4+ubuntu22.04_all.deb"
ZABBIX_RELEASE_URL="https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/$ZABBIX_RELEASE_PKG"

# Download and install Zabbix Agent repository
echo "Downloading and installing Zabbix Agent repository..."
wget -q $ZABBIX_RELEASE_URL -O /tmp/zabbix-release.deb
sudo dpkg -i /tmp/zabbix-release.deb
sudo apt update

# Installing Zabbix Agent
echo "Installing Zabbix Agent..."
sudo apt install -y zabbix-agent

# Configuring Zabbix Agent
echo "🛠 Configuring Zabbix Agent..."
sudo sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF
sudo sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" $ZABBIX_AGENT_CONF
sudo sed -i "s/^Hostname=.*/Hostname=$(hostname)/" $ZABBIX_AGENT_CONF

# Start and enable Zabbix Agent service
echo "Starting and enabling Zabbix Agent service..."
sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent

# Installation and configuration complete
echo "Installation and configuration complete!"
sudo systemctl status zabbix-agent --no-pager
