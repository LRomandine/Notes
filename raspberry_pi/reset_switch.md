# Pinout
[https://pinout.xyz/](https://pinout.xyz/)

# Components
- momentary switch

# Directions
Connect switch to GPIO and ground.  Suggest using BCM pin 3 due to the fixed 1.8 kohms pull up resistor.

```
#!/bin/bash

# Add a line to /etc/rc.local like
# /path/to/script.sh &

# Setup the GPIO
GPIO="3"
echo "$GPIO" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio"$GPIO"/direction

while :
do
    # check if the pin is connected to GND
    if [ $(</sys/class/gpio/gpio${GPIO}/value) == 0 ]; then
        shutdown -r now
    fi
    /bin/sleep 0.5
done
```
