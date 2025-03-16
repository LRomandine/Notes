# mealie_automated_backup.py

I wanted a way to back up my mealie install every week on a cron job that worked with my current backup strategy so I wrote this script and call it from my main backup script.

This script will
1. Create a new backup
2. Delete any backups over the number you specify
3. Exposes a status code (zero or one) so any calling script can execute appropriately
