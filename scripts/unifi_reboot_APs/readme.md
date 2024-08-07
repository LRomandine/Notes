# 15-reboot-aps.sh
- List all Unifi APs connected to UDM Pro and reboot them every week

# Requires unifios-utilities on-boot-script
[Install directions here](https://github.com/unifi-utilities/unifios-utilities/tree/main/on-boot-script)

# Install instructions
Assuming you have already installed on-boot-script
1. Enable SSH for devices with pre-shared keys
    1. Log into Unifi Web Console
    2. Go to Network app
    3. Settings -> System -> Advanced
    4. Enable "Device Authentication"
    5. Set the username to "root"
    6. Set a random password, we won't use it
    7. SSH into your UDM Pro and generate SSH keys `ssh-keygen` and just hit enter for the passphrase
    8. Get the contents of your SSH public key `cat /root/.ssh/id_rsa.pub`
    9. Copy that line of text and paste it into web console where it says "Should start with 'ssh-rsa'" and give it a name like "UDMP root"
    10. Save
2. Create an new user in the Unifi console with viewer permissions to network
    1. [Details on Ubiquiti website](https://help.ui.com/hc/en-us/articles/1500011491541-Granting-Access-to-UniFi-Roles-and-Permissions)
    2. [Example screenshot showing user](https://github.com/LRomandine/Notes/blob/master/scripts/unifi_reboot_APs/apiuser.png)
2. On your UDM Pro install this file
    1. In your SSH session install this file
    2. Edit the file with your API user password
```
cd /data/on_boot.d/
wget https://raw.githubusercontent.com/LRomandine/Notes/master/scripts/unifi_reboot_APs/15-reboot-aps.sh
chmod +x 15-reboot-aps.sh
# Execute now to enable the reboots
./15-reboot-aps.sh
# If you don't already have 25-add-cron-jobs.sh grab it
wget https://raw.githubusercontent.com/unifi-utilities/unifios-utilities/main/on-boot-script/examples/udm-files/on_boot.d/25-add-cron-jobs.sh
./25-add-cron-jobs.sh
```


## Example cron entries this creates
```
5 03 * * 1 root ssh -o StrictHostKeychecking=no 192.168.0.2 'reboot'
10 03 * * 1 root ssh -o StrictHostKeychecking=no 192.168.0.10 'reboot'
15 03 * * 1 root ssh -o StrictHostKeychecking=no 192.168.0.11 'reboot'
20 03 * * 1 root ssh -o StrictHostKeychecking=no 192.168.0.12 'reboot'
25 03 * * 1 root /sbin/reboot
```
