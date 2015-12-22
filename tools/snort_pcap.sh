#!/bin/sh
#
# Copyright 2004 Spanish Honeynet Project <project@honeynet.org.es>
# License BSD http://www.opensource.org/licenses/bsd-license.php
#
# NAME:        snort_pcap.sh
# DATE:        August, 2004
# VERSION:     0.1
# DESCRIPTION: Setup script for logging network traffic using snort
#

# Load variables
. /etc/default/honeywall.conf

# Script variables
RETVAL=0
BINARY=/usr/local/bin/snort
PATH=/bin:/usr/local/bin
PID=/var/run/snort_${LAN_IFACE}_pcap.pid
DIR="/var/log/snort"
DATE=`/bin/date +%Y%m%d`
CONF_FILE=/etc/snort/snort.conf
PROG=snort
USER=snort

if [ ! -x "$BINARY" ]; then
    echo "ERROR: $BINARY not found."
    exit 1
fi

if [ ! -r "$CONF_FILE" ]; then
    echo "ERROR: $CONF_FILE not found."
    exit 1
fi

start()
{
    # Check if log diratory is present. Otherwise, create it.
    if [ ! -d $DIR/$DATE ]; then 
        mkdir $DIR/$DATE
        chown -R $USER $DIR/$DATE
    fi
    /bin/echo "Starting $PROG: "
    # Snort parameters
    # -D Run Snort in background (daemon) mode
    # -i <if> Listen on interface <if> 
    # -u <uname> Run snort uid as <uname> user (or uid)
    # -l Log to directory
    # -L Log to a tcpdump file
    # -t Chroots process to directory after initialization
    # -R <id> Include 'id' in snort_intf<id>.pid file name
    
    $BINARY -D -i $LAN_IFACE -u $USER -l $DIR/$DATE -L tcpdump.$DATE -t $DIR/$DATE -R _pcap
    /bin/echo "$PROG startup complete."
    return $RETVAL
}

stop()
{
    if [ -s $PID ]; then
        /bin/echo "Stopping $PROG with PID `cat $PID`: "
        kill -TERM `cat $PID` 2>/dev/null
        RETVAL=$?
        /bin/echo "$PROG shutdown complete."
        rm -f $PID
    else
        /bin/echo "ERROR: PID in $PID file not found."
        RETVAL=1
    fi
    return $RETVAL
}

restart()
{
    stop
    start
    RETVAL=$?
    return $RETVAL
}

case "$1" in
 start)
       start
    ;;
 stop)
       stop
    ;;
 restart|reload)
       restart
    ;;
 *)
    /bin/echo "Usage: $0 {start|stop|restart|reload}"
    RETVAL=1
esac

exit $RETVAL 

