# Fix for google-musicmanager on CentOS 7
There is a dependency issue for google-musicmanager-beta-1.0.467.4929-0.x86_64 on CentOS systems (I assume other Red Hat based systems are affected).

# Add Google repo
## /etc/yum.repos.d/google-musicmanager.repo
```
[google-musicmanager]
name=google-musicmanager
baseurl=http://dl.google.com/linux/musicmanager/rpm/stable/x86_64
enabled=1
gpgcheck=1
```

## Add signing key
Taken from [Google Linux repo info](https://www.google.com/linuxrepositories/)
```shell
wget https://dl.google.com/linux/linux_signing_key.pub
sudo rpm --import linux_signing_key.pub
rpm -qi gpg-pubkey-7fac5991-*
```

# Fix Requirements
We need the rpmrebuild package to edit the dependencies, then they should download appropriately through yum.  We also need yumdownloader to download the RPM to edit it.
```
yum install rpmrebuild yumdownloader
```

# Perform the fix
## Modify the RPM
We use rpmrebuild to modify the dependencies so the package correctly recognizes qt5 as installed
```
yumdownloader google-musicmanager-beta
rpmrebuild -e -p google-musicmanager-beta-1.0.467.4929-0.x86_64.rpm
```
Around line 54 there should be
```
Requires:      qt5
```
Change it to be
```
Requires:      qt5-qtbase
```
Now save and quit your text editor, continue the rpmrebuild

## Install the new RPM
You may need to adjust the directory where your new RPM file is located
```
cd ~/rpmbuild/RPMS/x86_64/
yum localinstall google-musicmanager-beta-1.0.467.4929-0.x86_64.rpm
```
Yum should handle your dependencies properly now.

# Open application in GUI
- Log in
- Select folders
- yadda yadda yadda
- Add to autostart for your chosen GUI (requires gnome-tweak-tool)
    - Gnome Applications => Utilities => Tweak Tool => Startup Applications => Plus sign => select google music manager
