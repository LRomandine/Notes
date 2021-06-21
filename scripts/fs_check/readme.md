# fs_check.sh
- Check filesystems and email an alert if they are getting full
- Verify mdadm has MAILADDR correctly
- Check SMART status of all drives

## Example cron entry
```
# Check filesystem percent and email alarms
0 * * * * /root/scripts/fs_check.sh > /dev/null 2>&1
```
