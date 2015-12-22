#!/bin/sh
#
# Copyright 2004 Spanish Honeynet Project <project@honeynet.org.es>
# License BSD http://www.opensource.org/licenses/bsd-license.php
#
# NAME:        snort_inline.sh
# DATE:        August, 2004
# VERSION:     0.1
# DESCRIPTION: Setup script for running snort_inline
#

# Load variables
. /etc/default/honeywall.conf

# Script variables
RETVAL=0
BINARY=/usr/local/bin/snort_inline
PATH=/bin:/usr/local/bin
PID=/var/run/snort_inline.pid
DIR="/var/log/snort_inline"
DATE=`/bin/date +%Y%m%d`
CONF_FILE=/etc/snort_inline/snort_inline.conf
PROG=snort_inline
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
    # Check if log directory is present. Otherwise, create it.
    if [ ! -d $DIR/$DATE ]; then 
        mkdir $DIR/$DATE
        chown -R $USER $DIR/$DATE
    fi
    /bin/echo "Starting $PROG: "
    # Snort_inline parameters
    # -D Run snort_inline in background (daemon) mode
    # -Q Use ip_queue for input vice libpcap (iptables only)
    # -u <uname> Run snort_inline uid as <uname> user (or uid)
    # -c Load configuration file
    # -N Turn off logging (alerts still work)
    # -l Log to directory
    # -t Chroots process to directory after initialization
    
    $BINARY -D -Q -u $USER -c $CONF_FILE -N -l $DIR/$DATE -t $DIR/$DATE
    /bin/echo "$PROG startup complete."
    return $RETVAL
}

stop()
{
    if [ -s $PID ]; then
        /bin/echo "Stopping $PROG, with PID `cat $PID`: "
        kill -TERM `cat $PID`
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

