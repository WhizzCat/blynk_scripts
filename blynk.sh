#!/bin/bash
#

BASE=/tmp
PID=$BASE/blynk.pid
LOG=$BASE/blynk.log
ERROR=$BASE/blynk-error.log

COMMAND="/storage/java/jre/bin/java -jar /storage/blynk/server.jar"

status() {
	echo
	echo "==== Status"

	if [ -f $PID ]
	then
		echo
		echo "Pid file: $( cat $PID ) [$PID]"
		echo
		ps -ef | grep -v grep | grep $( cat $PID )
	else
		echo
		echo "No Pid file"
	fi
}

start() {
	if [ -f $PID ]
	then
		echo
		echo "Already started. PID: [$( cat $PID )]"
	else
		echo "==== Starting"
		touch $PID
		if nohup $COMMAND >>$LOG 2>&1 &
		then
			echo $! >$PID
			echo "Done"
			echo "$(date '+%Y-%m-%d %X'): START" >>$LOG
		else
			echo "Error"
			/bin/rm $PID
		fi
	fi
}

kill_cmd() {
	SIGNAL=""; MSG="Killing "
	while true
	do
		LIST=`ps -ef | grep -v grep | grep server.jar | awk '{print$1}'`
		if [ "$LIST" ]
		then
			echo; echo " $MSG $LIST" ; echo
			echo $LIST | xargs kill $SIGNAL
			sleep 2
			SIGNAL="-9" ; MSG="Killing $SIGNAL"
			if [ -f $PID ]
			then
				/bin/rm $PID
			fi
		else
			echo; echo "All killed" ; echo
			break
		fi
	done
}

stop() {
    echo "==== Stop"

    if [ -f $PID ]
    then
        if kill $( cat $PID )
        then echo "Done."
             echo "$(date '+%Y-%m-%d %X'): STOP" >>$LOG
        fi
        /bin/rm $PID
        kill_cmd
    else
        echo "No pid file. Already stopped?"
    fi
}

case "$1" in
    'start')
            start
            ;;
    'stop')
            stop
            ;;
    'restart')
            stop ; echo "Sleeping..."; sleep 1 ;
            start
            ;;
    'status')
            status
            ;;
    *)
            echo
            echo "Usage: $0 { start | stop | restart | status }"
            echo
            exit 1
            ;;
esac

exit 0
