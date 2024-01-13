#!/bin/sh

# Discover all APs
ubnt-tools ubnt-discover > /tmp/UAP-list
cat /tmp/UAP-list | grep UAP |awk '{print $2}' | sort> /tmp/UAP-list-IPs

# Save our current crontab
crontab -l > /tmp/rootcrontab

# Loop through our discovered APs and create a crontab line for each in ascending order
COUNTER=$(expr 0)
while read IP; do
    COUNTER=$(expr $COUNTER + 5)
    echo "${COUNTER} 03 * * 1 ssh ${IP} 'shutdown -r now'" >> /tmp/rootcrontab
done < /tmp/UAP-list-IPs

# Install the new crontab
crontab /tmp/rootcrontab

# Cleanup
rm /tmp/rootcrontab
rm /tmp/UAP-list
rm /tmp/UAP-list-IPs











