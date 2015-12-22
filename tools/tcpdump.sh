#!/bin/sh
#
# Copyright 2004 Spanish Honeynet Project <project@honeynet.org.es>
# License BSD http://www.opensource.org/licenses/bsd-license.php
#
# NAME:        tcpdump.sh
# DATE:        August, 2004
# VERSION:     0.1
# DESCRIPTION: Setup script for logging network traffic using tcpdump
#
# Comments: The default log directory is /var/log/tcpdump
#           The filter file is optional
#

# Load global variables
. /etc/default/honeywall.conf

# Script variables
RETVAL=0
BINARY=/usr/sbin/tcpdump
PATH=/bin:/usr/local/bin
FILTER_FILE=/etc/tcpdump/tcpdump.filter
DATE=`/bin/date +%Y%m%d`
LOG_DIR=/var/log/tcpdump
LOG_FILE=tcpdump.log.`/bin/date +%s`
PROG=tcpdump

if [ ! -x "$BINARY" ]; then
    echo "ERROR: $BINARY not found."
    exit 1
fi

start()
{
    # Check if log directory is present. Otherwise, create it.
    if [ ! -d $LOG_DIR/$DATE ]; then
        mkdir $LOG_DIR/$DATE
        chown -R $USER $LOG_DIR/$DATE
    fi
    /bin/echo "Starting $PROG: "
    if [ -s "$FILTER_FILE" ]; then
        $BINARY -i $LAN_IFACE -F $FILTER_FILE -w $LOG_DIR/$DATE/$LOG_FILE &
    else
        $BINARY -i $LAN_IFACE -w $LOG_DIR/$DATE/$LOG_FILE &
    fi
    /bin/echo "$PROG startup complete."
    return $RETVAL
}

stop()
{
    /bin/echo "Stopping $PROG: "
    for pid in `/sbin/pidof $PROG`; do
        /bin/kill -TERM $pid 2>/dev/null
        RETVAL=$?
    done
    /bin/echo "$PROG shutdown complete."
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


