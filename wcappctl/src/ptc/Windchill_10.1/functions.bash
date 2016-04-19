# private functions
_version_logs() {
	local root="$(dirname $1)"
	local log="$(basename $1)"
	local timestamp="$2"
	
	local pat=${log}.${timestamp}.[0-9]*.gz
	for f in $(ls $root/$log.${timestamp}.*.gz 2>/dev/null | sort -r); do
		n=$(ls $f | awk -F '.' "/${pat}/ {print \$5}")
		if [[ -n "$n" ]]; then
			i=$(($n + 1 ))
		else
			# non-versioned gzipped logs sort first
			continue
		fi
		newfile=$root/$log.${timestamp}.${i}.gz
		mv $f $newfile
	done
	
	if [ -f $root/$log.${timestamp}.gz ]; then
		mv $root/$log.${timestamp}.gz ${LOG}.${timestamp}.1.gz
	fi
}

# Override the function in /etc/init.d/functions, because it's too greedy
__pids_pidof() {
	pidof -c -o $$ -o $PPID -o %PPID -x "$1"
}

# public functions
function get_uid() {
	echo "$EUID"
}
	
function rotate_log() {
	local logfile=$1
	local timestamp="$(date +%Y%m%d)"
	
	_version_logs $logfile $timestamp >/dev/null
	if [ -f $logfile ]; then
		newlogfile=$logfile.$timestamp
		cp $logfile $newlogfile
		cat /dev/null > $logfile
		gzip -f -9 $newlogfile
	fi
}

function log() {
	echo "$1" >> $LOG | tee >&1
}

function ds() {
	msg="WindchillDS server "
	case "$1" in
		start)
			msg+="starting... "
			log "$msg"
			$IS_STARTED "$DS_PID" "$DS_PROC" "$DS_PROC_VERIFY"
			RETVAL=$?
			if [ $RETVAL -ne 0 ]; then
				$START_DS 2>&1 | tee -a $LOG
				RETVAL="${PIPESTATUS[0]}"
			fi
		;;
		stop)
			msg+="stopping... "
			log "$msg"
			is_stopped "$DS_PID" "$DS_PROC" "$DS_PROC_VERIFY"
			RETVAL=$?
			if [ $RETVAL -ne 0 ]; then
				$STOP_DS 2>&1 | tee -a $LOG
				RETVAL="${PIPESTATUS[0]}"
			fi
		;;
	esac
	
	case "$RETVAL" in
		0)
			echo -n "$msg" && echo_success
		;;
		*)
			echo -n "$msg" && echo_failure
		;;
	esac
	
	echo

	[ $RETVAL -gt 0 ] && RETVAL=1
	
	return $RETVAL
}

function is_started() {
	local pidfile=$1
	local cmd=$2
	local proc_str=
	
	if [ $# -eq 3 ]; then
		proc_str="$3"
	fi
	
	if [ -f $pidfile ]; then
		# return if process is already running
		$(checkpid $(cat $pidfile))
		[ $? -eq 0 ] && return 0
		
		# process not running but pid exists?  kill pid file
		rm -f $pidfile
	fi
	
	# no pid file but verify by looking for running process
	pid=$(find_parent_pid "$cmd" $proc_str)

	#if a process is running, create a new pidfile
	if [[ -n "$pid" && "$pid" -ne 0 ]]; then
		log "found pid from running process list, writing it to $pidfile"
		write_pid $cmd $pidfile $pid
		return 0
	fi
	
	return 1
}

function find_parent_pid() {
	local cmd=$1
	local str=
	
	if [ $# -eq 2 ]; then
		# escape any path delimeters in the string
		str="$(echo "$2" | sed 's|/|\\/|')"
	fi		
	
	# sort the pids, so the parent process comes first 
	pids=$(echo $(pidofproc "$cmd" | tr " " "\n" | sort -n))
	[ -z "$pids" ] && echo "0" && return

	# if we are looking for a string to identify the correct process,
	#+ search the ps output to verify the pid belongs to a specific command.  If
	#+ there's no string to match, just return the lowest pid as the parent.  Note,
	#+ this is not fool-proof logic and assumes a parent-child relationship
	if [ -n "$str" ]; then
		for pid in $pids; do
			if [ -n $(ps -p $pid -f|awk "/$str/ {print \$8}") ]; then
				break
			fi
		done
	else
		a=($pids)
		pid=${a[0]}
	fi

	echo $pid
}

function is_stopped() {
	$IS_STARTED $1 $2 $3
	if [ $? -eq 0 ];then
		RETVAL=1
	else
		RETVAL=0
	fi
	
	return $RETVAL
}

function windchill() {
	local msg="Windchill server "
	case "$1" in
		start)
			msg+="starting... "
			log "$msg"
			$IS_STARTED "$WINDCHILL_PID" "$WINDCHILL_PROC" "$WINDCHILL_PROC_VERIFY"
		;;
		stop)
			msg+="stopping... "
			log "$msg"
			is_stopped "$WINDCHILL_PID" "$WINDCHILL_PROC" "$WINDCHILL_PROC_VERIFY"
		;;
	esac
	
	RETVAL=$?
	if [ $RETVAL -ne 0 ]; then
		$WINDCHILL $@ 2>&1 | tee -a $LOG
		RETVAL="${PIPESTATUS[0]}"
	fi
	
	case "$RETVAL" in
		0)
			echo -n "$msg"
			if [ "$1" = "start" ]; then
				$IS_STARTED "$WINDCHILL_PID" "$WINDCHILL_PROC" "$WINDCHILL_PROC_VERIFY"
				if [ $? -eq 0 ]; then
					echo_success
				else
					echo_failure
				fi
			else
				is_stopped "$WINDCHILL_PID" "$WINDCHILL_PROC" "$WINDCHILL_PROC_VERIFY"
				if [ $? -eq 0 ]; then
					echo_success
					rm -f $WINDCHILL_PID &>/dev/null
				else
					echo_failure
				fi
			fi
		;;
		*)
			echo -n "$msg" && echo_failure
		;;
	esac
		
	echo
		
	return ${RETVAL}
}

function write_pid() {
	local comm=$1
	local pidfile=$2
	local pid=$3
	
	if [ -f "$pidfile" ]; then
		$(checkpid $(cat $pidfile))
		is_running=$?
		if [ $is_running -eq 0 ]; then 
			echo "$comm ($pid) is currently running." | tee -a $LOG
			return $is_running
		else
			echo "pid file exists but process stopped.  Removing pid file." | tee -a $LOG
			rm -f $pidfile
		fi
	fi
	
	echo $pid > $pidfile
	
	return 0
}

function wc_httpd() {
	local msg="HTTP server "
	case "$1" in
		start)
			msg+="starting... "
			log "$msg"
			$IS_STARTED $HTTPD_PID $HTTPD_PROC
		;;
		stop | graceful | graceful-stop)
			msg+="stopping... "
			log "$msg"
			is_stopped $HTTPD_PID $HTTPD_PROC
		;;
	esac	
	
	RETVAL=$?
	if [ $RETVAL -ne 0 ]; then
		$APACHE_CTL $@ 2>&1 | tee -a $LOG
		RETVAL="${PIPESTATUS[0]}"
	fi
	
	case "$RETVAL" in
		0)
			echo -n "$msg" && echo_success
		;;
		*)
			echo -n "$msg" && echo_failure
		;;
	esac
	
	echo
	
	return $RETVAL
}

function my_status() {
	declare -a argAry=("${!1}")
	for entry in "${argAry[@]}"; do
		name=${entry%%:*}
		pid=${entry#*:}
		status -p $pid $name
	done
}

function is_listener_active() {
	local server=$1
	local port=$2
	local RETVAL=1
	
	ping $server -c 1 | grep "1 packets transmitted, 1 received"
	if [ $? -eq 0 ]; then
		(
		 echo "open $server $port"
		 echo "quit"
		) | telnet 2>&1 | grep "Connection closed"
		
		RETVAL=${PIPESTATUS[2]}
		[ "$RETVAL" -ne 0 ] && log "$server does not have a listener on port $port"
	else
		log "Could not connect to server, $server"
	fi

	return $RETVAL
}
