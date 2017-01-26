# Crashplan on Linux
During a Linux major OS version upgrade Crashplan was being a pain with wanting to adopt the old backup, syncing data, and taking forever on a large backup set.  So I figured out how to migrate the install.


## Migrate Crashplan to new OS install on same machine
- Same OS type
    - Tested on CentOS 6.8 to CentOS 7.3
- Same storage locations
    - Backup selection
    - Incoming backup location
    - Installation location
    
### Files to back up
```
# Default install location, this may be different depending on your choice during install
# This includes the cache directory which holds sync information, this saves TONS of time with large backup sets
/usr/local/crashplan
# This holds your UUID, login hash, etc. in two hidden files
/var/lib/crashplan
```

### After Upgrade
1. Install Crashplan per Code 42's instructions
    1. Use the same install location as before
1. Once installation is complete shut down the engine
    1. ```service crashplan stop```
1. Delete everything the install created inside the two directories we backed up. (The install did more stuff that we want, thats why we still go through the install)
    1. ```rm -rf /usr/local/crashplan/*```
    1. ```rm -rf /var/lib/crashplan/.*```
1. Restore the data you backed up to the two locations
1. Change permissions on the ui* files
    1. ```chmod 777 /usr/local/crashplan/log/ui*```
    1. This allows you to run the GUI as any user on the system, you could also ```chown``` the files.
1. Start the crashplan service
    1. ```service crashplan start```
1. Wait a few minutes and then start up the GUI
    1. ```/usr/local/crashplan/bin/CrashPlanDesktop```
1. If successful Crashplan should look identical to the way it did before the upgrade.
