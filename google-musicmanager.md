# Install Google GPG key
Taken from https://www.google.com/linuxrepositories/
```shell
wget https://dl.google.com/linux/linux_signing_key.pub
sudo rpm --import linux_signing_key.pub
rpm -qi gpg-pubkey-7fac5991-*
```

# Install from RPM
```shell
wget "http://dl.google.com/linux/direct/google-musicmanager-beta_current_x86_64.rpm"
rpm --checksig -v google-musicmanager-beta_current_x86_64.rpm
sudo yum localinstall -y google-musicmanager-beta_current_x86_64.rpm
```

# Remove silly daily cron files
```shell
rm /etc/cron.daily/google-musicmanager
rm /etc/default/google-musicmanager
```

# Open application in GUI
- Log in
- Select folders
- yadda yadda yadda
- Add to autostart for your chosen GUI
    - Gnome Applications => System Tools => Startup Applications
        - add /opt/google/musicmanager/google-musicmanager



