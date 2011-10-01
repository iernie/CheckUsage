#!/bin/sh
#
# CheckUsage
#
# Author: iernie
# Version: 1.2.0
# Date: 20111002
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
DATE=`date +%D`
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

getDivisionNumber() {
    DIV=$(($AMOUNT / $LIMIT))
    FLOOR=$(echo $DIV | cut -d"." -f1)
    echo "$FLOOR"
}

getFormattedDate() {
    MONTH=`date +%m`
    YEAR=`date +%Y`
    DAY=`date +%d`
	echo "$YEAR$MONTH$DAY"
}

getLastChanged() {
    NUMB=`getDivisionNumber`
    DATE=`getFormattedDate`
    echo "$NUMB:$DATE"
}

updateLastChanged() {
	rm lastchange 
	getLastChanged >> lastchange
}

case "$1" in
	force)
		echo "Force changing MAC..."
		#changeMac
		updateLastChanged
	;;
	*)
		if ! [[ -f lastchange ]]; then
			echo "0:19700101" >> lastchange
		fi
		LAST=`cat lastchange`
		LASTNUMB=$(echo $LAST | cut -d":" -f1 | cut -d"." -f1)
		NUMB=`getDivisionNumber`
		LASTDATE=$(echo $LAST | cut -d":" -f2)
		DATE=`getFormattedDate`
		if [ $UNIT == $LIMITSTR ] && [ $NUMB -gt $LASTNUMB ] && [ $DATE -gt $LASTDATE ]; then
		    echo "Total network traffic has exceeded limit: $AMOUNT $UNIT / $LIMIT $LIMITSTR"
		    #changeMac
		    updateLastChanged
		    ifconfig $INTERFACE
		else
		    echo "Some requirements not met. Not changing mac."
	    fi
esac
exit 0
