#!/bin/sh

# Local User Password
#    Update this with a local Unifi user so the API calls work
LOCAL_USER_PW=''


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

# Discover all WAPs
ubnt-tools ubnt-discover | grep UAP |awk '{print $2}' | sort > /tmp/unifi-list-IPs

# Discover all switches
# Generate cookie file
curl -s -k -X POST --data "{\"username\": \"apiuser\", \"password\": \"${LOCAL_USER_PW}\"}" --header 'Content-Type: application/json' -c /data/.cookie.txt https://127.0.0.1:443/api/auth/login
# Get switch mac addresses (one per line)
curl -s -k -X GET -b /data/.cookie.txt "https://127.0.0.1/proxy/network/api/s/default/stat/device-basic" | jq -c -r '.data | .[] | select( .model | startswith("US")).mac' > /tmp/switch_macs
# Get switch IP address
while read MAC; do
    curl -s -k -X GET -b /data/.cookie.txt "https://127.0.0.1/proxy/network/api/s/default/stat/device/${MAC}" | jq -c -r '.data | .[] | .connect_request_ip' >> /tmp/unifi-list-IPs
done < /tmp/switch_macs

# Sort our list
sort -t . -n -k 4,4 /tmp/unifi-list-IPs > /tmp/unifi-sorted-IPs

# Loop through our discovered WAPs and create a crontab line for each in ascending order
echo 'MAILTO=""' > ${DATA_DIR}/cronjobs/reboot-aps
COUNTER=$(expr 0)
while read IP; do
    COUNTER=$(expr $COUNTER + 5)
    echo "${COUNTER} 03 * * 1 root ssh -o StrictHostKeychecking=no ${IP} 'reboot'" >> ${DATA_DIR}/cronjobs/reboot-aps
done < /tmp/unifi-sorted-IPs

# Reboot self at the end
COUNTER=$(expr $COUNTER + 5)
echo "${COUNTER} 03 * * 1 root /sbin/reboot" >> ${DATA_DIR}/cronjobs/reboot-aps

# Install the new crontab will be done via script 25-add-cron-jobs.sh
#    https://github.com/unifi-utilities/unifios-utilities/blob/main/on-boot-script/examples/udm-files/on_boot.d/25-add-cron-jobs.sh
#        As of August, 2024 you will need to edit the case statement to include a 4*) section like lines 19-21 in this file, Ubiquiti updated firmware to 4.x

# Cleanup
rm /tmp/unifi-list-IPs
rm /tmp/switch_macs
rm /tmp/unifi-sorted-IPs
