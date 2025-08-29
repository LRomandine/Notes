#!/bin/bash

# Local User Password
LOCAL_USER_PW='REPLACE_ME'


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
4*)
    DATA_DIR="/data"
    ;;
*)
    echo "ERROR: No persistent storage found." 1>&2
    exit 1
    ;;
esac

# Log a little
echo "`date +%Y-%m-%dT%T%:z` `hostname` 15-reboot-waps[$$]: Ran script" >> /var/log/cron.log

# Discover all WAPs
# This was unreliable
#ubnt-tools ubnt-discover | grep UAP |awk '{print $2}' | sort > /tmp/unifi-list-IPs

# Discover all Unifi devices
# Generate cookie file
curl -s -k -X POST --data "{\"username\": \"apiuser\", \"password\": \"${LOCAL_USER_PW}\"}" --header 'Content-Type: application/json' -c /data/.cookie.txt https://127.0.0.1:443/api/auth/login
# Get device mac addresses (one per line)
DEVICES_JSON=$(curl -s -k -X GET -b /data/.cookie.txt "https://127.0.0.1/proxy/network/api/s/default/stat/device-basic")
# Get all non UDM devices
echo "${DEVICES_JSON}" | jq -c -r '.data | .[] | select( .model | startswith("UDM")|not).mac' > /tmp/device_macs
# Get device IP address
while read MAC; do
    curl -s -k -X GET -b /data/.cookie.txt "https://127.0.0.1/proxy/network/api/s/default/stat/device/${MAC}" | jq -c -r '.data | .[] | .connect_request_ip' >> /tmp/unifi-list-IPs
done < /tmp/device_macs
# Sort our list, reverse sort so our switch is at the bottom (in my case, you may need to change or you may not care)
sort -r -t . -n -k 4,4 /tmp/unifi-list-IPs > /tmp/unifi-sorted-IPs

# Loop through our discovered devices and create a crontab line for each in ascending order
echo 'MAILTO=""' > ${DATA_DIR}/cronjobs/reboot-aps
COUNTER=$(expr 0)
while read IP; do
    COUNTER=$(expr $COUNTER + 5)
    # SSH will sometimes randomly not work unless we try to SSH then wait 30 seconds. No clue why.
    if [[ "${COUNTER}" -eq 5 ]]; then
        echo "${COUNTER} 04 * * 1 root ssh -o StrictHostKeychecking=no ${IP} ':'" >> ${DATA_DIR}/cronjobs/reboot-aps
        COUNTER=$(expr $COUNTER + 5)
    fi
    echo "${COUNTER} 04 * * 1 root ssh -o StrictHostKeychecking=no ${IP} 'reboot'" >> ${DATA_DIR}/cronjobs/reboot-aps
done < /tmp/unifi-sorted-IPs

# Reboot self at the end
COUNTER=$(expr $COUNTER + 5)
echo "${COUNTER} 04 * * 1 root /sbin/reboot" >> ${DATA_DIR}/cronjobs/reboot-aps

# Install the new crontab will be done via script 25-add-cron-jobs.sh
#    https://github.com/unifi-utilities/unifios-utilities/blob/main/on-boot-script/examples/udm-files/on_boot.d/25-add-cron-jobs.sh

# Need to set up a cron job to refresh/update the list of unifi devices on the network
echo 'MAILTO=""' > ${DATA_DIR}/cronjobs/refresh-unifi-list
echo "1 04 * * 1 root ${DATA_DIR}/on_boot.d/15-reboot-waps.sh" >> ${DATA_DIR}/cronjobs/refresh-unifi-list
echo "3 04 * * 1 root ${DATA_DIR}/on_boot.d/25-add-cron-jobs.sh" >> ${DATA_DIR}/cronjobs/refresh-unifi-list

# Cleanup
rm /tmp/unifi-list-IPs
rm /tmp/device_macs
rm /tmp/unifi-sorted-IPs
