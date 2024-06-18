#!/bin/sh

DATA_DIR="/data"
case "$(ubnt-device-info firmware || true)" in
1*)
    DATA_DIR="/mnt/data"
    ;;
2*)
    DATA_DIR="/data"
    ;;
3*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac

# Discover all WAPs
ubnt-tools ubnt-discover > /tmp/UAP-list
cat /tmp/UAP-list | grep UAP |awk '{print $2}' | sort> /tmp/UAP-list-IPs

# Loop through our discovered WAPs and create a crontab line for each in ascending order
echo 'MAILTO=""' > /tmp/rootcrontab
COUNTER=$(expr 0)
while read IP; do
    COUNTER=$(expr $COUNTER + 5)
    echo "${COUNTER} 03 * * 1 root ssh -o StrictHostKeychecking=no ${IP} 'reboot' && echo \"\`date +'%Y-%m-%d %H:%M:%S'\` - Reboot ${IP}\" >> /var/log/reboots.log 2>&1" >> /tmp/rootcrontab
done < /tmp/UAP-list-IPs

# Install the new crontab will be done via script 25-add-cron-jobs.sh
#    https://github.com/unifi-utilities/unifios-utilities/blob/main/on-boot-script/examples/udm-files/on_boot.d/25-add-cron-jobs.sh

# Cleanup
rm /tmp/rootcrontab
rm /tmp/UAP-list
rm /tmp/UAP-list-IPs
