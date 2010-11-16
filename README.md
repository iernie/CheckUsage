CheckUsage
====

*A small shell script that uses vnstat to check the total network usage per day and change the MAC address if the usage exceeds the set amount*

What it does is check if the network usage has exceeded the set limit by getting daily data from vnstat. If it has exceeded it changes the MAC address by increasing the last two digit in the MAC address by one. If this number goes over 50, it jumps down to 10 and starts over and so forth.

# Dependencies

* Vnstat must be installed and running
* OpenWRT based router

## Setup

* Download the script and place it where you want (eg. /bin/checkusage.sh).
* Edit the file and configure (See below for configuration details).
* Chmod a+x to make the script executable.
* Add the script to crontab to check as often as you like.

## Crontab

To add the script to check once a day simply type *crontab -e* and add the line *0 11 \* \* \* /bin/checkusage.sh* to use the script at 11 o'clock each day.
Remember to restart cron by typing */etc/init.d/cron -restart*

## Configurations

* LIMIT is the limit you don't want your network usage to exceed. Based on LIMITSTR for unit.
* LIMISTR is the unit of which the limit should be in (eg. GiB, MiB, KiB).
* PREFIX is the 5 first numbers of the MAC address you want to use. The last two will be automatically generated if the usage exceeds the limit.
* INTERFACE is the interface your router uses to connect to internet (wan) (eg. eth0, eth1 etc).

## Known supported devices

* WNDR3700 running OpenWRT 10.03.1-RC3

# Disclaimer

I am not responsible for any damage done by this script, although it should be harmless in theory. I cannot promise that it will work on your device, but I would be happy to know if it did.