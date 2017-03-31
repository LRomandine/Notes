# Two ways to hook up fan

## Pinout
[https://pinout.xyz/](https://pinout.xyz/)

## Not Controlled
Components
- 5V 2 wire fan

Directions
- Plug directly into header where a 5V and ground are next to each other.
 - On Raspberry pi 3 b a good example are pins 4 and 6

## Controlled
Components
- 5V 2 wire fan
- S8050 NPN transistor

Directions
- NPN transistor has 3 legs: emitter, collector, and base
    - Emitter is negative/ground
    - Collector is positive
    - Base is the control (5V=on, 0v=Off)
- Wire it up so that 
```
5V ------> fan  -----> collector
GPIO ----> base
Ground --> emitter
```

# Bash script for fan control
```
#!/bin/bash

# Setup the GPIO
GPIO="18"
echo "${GPIO}" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio${GPIO}/direction

while :
do
    export TEMP=$(vcgencmd measure_temp|awk -F'=' '{print $2}'|awk -F'.' '{print $1}')
    if (( $TEMP >= 60 ));then
        echo 1 > /sys/class/gpio/gpio${GPIO}/value
    elif (( $TEMP <= 50 ));then
        echo 0 > /sys/class/gpio/gpio${GPIO}/value
    fi
    /bin/sleep 10
done
```
