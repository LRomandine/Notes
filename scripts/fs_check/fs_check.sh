#!/bin/bash

MAIL_ADDRESS='user@example.com'
RAID_FS_MAX='95'
NORMAL_FS_MAX='80'
TMP_FS_MAX='50'

############################################################################################
### Check used % on non-RAID filesystems
############################################################################################
#Must set IFS to newline
IFS=$'\n'
for DF_LINE in `df -h|grep -v Filesystem|grep -v '/dev/loop'|awk '{print $1 " " $5 " " $6}'`;do
    FS_TYPE=`echo $DF_LINE|awk '{print $1}'`
    USE_PERCENT=`echo $DF_LINE|awk '{print $2}'|awk -F'%' '{print $1}'`
    FS_MOUNT=`echo $DF_LINE|awk '{print $3}'`
    if [[ `echo $FS_TYPE|grep '/dev/md'` != "" ]];then
        #RAID ARRAY
        FS_PERCENT="${RAID_FS_MAX}"
    elif [[ `echo $FS_TYPE|grep 'tmpfs'` != "" ]];then
        #systemctl tmpfs
        FS_PERCENT="${TMP_FS_MAX}"
    else
        # Normal FS
        FS_PERCENT="${NORMAL_FS_MAX}"
    fi
    if (( ${USE_PERCENT} > ${FS_PERCENT} ));then
        echo "Filesystem '${FS_MOUNT}' is ${USE_PERCENT} % full which is over ${FS_PERCENT} % threshold, alerting!"
        logger "Filesystem '${FS_MOUNT}' is ${USE_PERCENT} % full which is over ${FS_PERCENT} % threshold, alerting!"
        df -h > /tmp/df.output
        mailx -s "Filesystem Space Alarm on SKYNET" ${MAIL_ADDRESS} < /tmp/df.output
        rm -f /tmp/df.output
    else
        echo "Filesystem '${FS_MOUNT}' is ${USE_PERCENT} % full which is under ${FS_PERCENT} % threshold, all is well."
    fi
done


############################################################################################
### Check used % on RAID filesystems
############################################################################################
for RAID_ARRAY in $(grep ARRAY /etc/mdadm.conf|awk '{print $2}'|awk -F'/' '{print $3}'); do
    if [[ `grep -A 3 ${RAID_ARRAY} /proc/mdstat | awk 'NF > 0'|grep algorithm|awk '{print $NF}'|egrep '^\[U*\]$'` = "" ]];then
        echo "Found a RAID array event on ${RAID_ARRAY}, alerting!"
        logger "Found a RAID array event on ${RAID_ARRAY}, alerting!"
        mailx -s "RAID array event" ${MAIL_ADDRESS} < /proc/mdstat
    else
        echo "RAID array ${RAID_ARRAY} is online and has all members, all is well."
    fi
done


############################################################################################
### Verify mdadm has MAILADDR listed
############################################################################################
if [[ `cat /etc/mdadm.conf|grep MAILADDR|grep ${MAIL_ADDRESS}` = "" ]];then
    echo "Missing MAILADDR in /etc/mdadm.conf, adding it and emailing!"
    logger "Missing MAILADDR in /etc/mdadm.conf, adding it and emailing!"
    echo "MAILADDR ${MAIL_ADDRESS}" >> /etc/mdadm.conf
    mailx -s "RAID Configuration Issue, missing MAILADDR" ${MAIL_ADDRESS} < /etc/mdadm.conf
else
    echo "MAILADDR is in /etc/mdadm.conf, all is well."
fi


############################################################################################
### Check SMART status for all attached drives
############################################################################################
for DISK in $(sfdisk -l 2>/dev/null|egrep 'Disk \/dev\/sd.:'|awk '{print $2}'|sed 's/://g'); do
    for RESULT in $(smartctl -a ${DISK}|egrep 'Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable|Seek_Error_Rate'|awk '{print $10}'); do
        if [[ "${RESULT}" != '0' ]];then
            smartctl -a ${DISK} | mailx -s "Hard Drive SMART Scan Error Found" ${MAIL_ADDRESS}
        else
            echo "Hard drive SMART status is good for ${DISK}"
        fi
    done
done
