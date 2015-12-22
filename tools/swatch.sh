#!/bin/sh
#
# Copyright 2004 Spanish Honeynet Project <project@honeynet.org.es>
# License BSD http://www.opensource.org/licenses/bsd-license.php
#
# NAME:        swatch.sh
# DATE:        August, 2004
# VERSION:     0.1
# DESCRIPTION: Setup script for running Swatch
#

# Load variables
. /etc/default/honeywall.conf

# Script variables
RETVAL=0
BINARY=/usr/bin/swatch
PATH=/bin:/usr/local/bin:/usr/bin
CONF_FILE=/etc/swatch/swatch.conf
PROG=swatch

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
   /bin/echo "Starting $PROG: "
   # Launch one Swatch process for each file included in $WATCH_FILES var
   for FILE in $WATCH_FILES; do
       $BINARY --config-file=$CONF_FILE --tail-file=$FILE --daemon &
   done
   /bin/echo "$PROG startup complete."
   return $RETVAL
}

stop()
{
   /bin/echo "Stopping $PROG: "
   for PID in `/sbin/pidof $PROG`; do
       /bin/kill -TERM -$PID 2>/dev/null
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

