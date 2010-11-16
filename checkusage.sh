#!/bin/sh
#
# CheckUsage
#
# Author: iernie
# Version: 1.0.5
# Date: 20101116
# Github: https://github.com/iernie/CheckUsage

# Dependencies: vnstat installed and running

######################
### CONFIGURATIONS ###
######################
LIMIT=8                 # Limit for network traffic
LIMITSTR=GiB            # The unit to check after; GiB, MiB, KiB
PREFIX="XX:XX:XX:XX:XX" # The prefix for the mac you want to use. Note: Use only the first five numbers.
INTERFACE="eth1"        # The interface for your wan

############
### CODE ###
############
MONTH=`date +%m`
YEAR=`date +%y`
DAY=`date +%d`
DATE="$MONTH/$DAY/$YEAR"
OUTPUT=`vnstat -d | grep $DATE | cut -d\| -f3`
AMOUNT=$(echo $OUTPUT | cut -d" " -f1 | cut -d"." -f1)
UNIT=$(echo $OUTPUT | cut -d" " -f2)
IF=`ifconfig $INTERFACE | grep HWaddr | cut -d":" -f7`
CURRENT=$(echo $IF | cut -d" " -f1)

changeMac() {
        echo "Old MAC: $PREFIX:$CURRENT"
        if [ $CURRENT -lt 50 ]; then
                NEW=`expr $CURRENT + 1`
                MAC="$PREFIX:$NEW"
        else
                MAC="$PREFIX:10"
        fi
        echo "New MAC: $MAC"
        ifdown
        ifconfig $INTERFACE down
        uci set network.wan.macaddr="$MAC"
        uci commit network
        ifconfig $INTERFACE hw ether $MAC
        ifconfig $INTERFACE up
        ifup wan
        echo "Mac Change Complete!"
}

if [ $UNIT == $LIMITSTR ]; then
        echo "Unit is right: $LIMITSTR"
        if [ $AMOUNT -ge $LIMIT ]; then
                echo "Total network traffic has exceeded limit: $AMOUNT $UNIT / $LIMIT $LIMITSTR"
                changeMac
                ifconfig $INTERFACE
        else
                echo "Total network traffic has not yet exceeded the limit: $AMOUNT $UNIT / $LIMIT $LIMITSTR"
        fi
else
        echo "Unit is not right: $UNIT"
fi
