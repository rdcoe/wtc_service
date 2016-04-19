# mock functions to override standard behaviour

_strip_newlines() {
	echo $1 | perl -ne 'chomp and print'
}
	
function get_uid() {
	echo "0"
}

function is_started_returns_0() {
	return 0
}

function is_started_returns_1() {
	return 1
}

function is_started_returns_0_then_returns_1() {
	IS_STARTED=is_started_returns_1

	return 0
}

function is_started_returns_1_then_returns_0() {
	IS_STARTED=is_started_returns_0
	
	return 1
}
	
function mock_start_ds() {
	(echo "start-ds returned exit code \"$1\"" && exit $1)
}

function mock_stop_ds() {
	(echo "stop-ds returned exit code \"$1\"" && exit $1)
}

function mock_windchill() {
	(echo "windchill $2 returned exit code \"$1\"" && exit $1)
}

function mock_apachectl() {
	(echo "httpd $2 returned exit code \"$1\"" && exit $1)
}

function mock_pidofproc() {
	if [ $# -eq 1 ]; then 
		if [[ $1 =~ ^-?[0-9]+$ ]]; then
			pid=$1
		else
			pid=0
		fi 
	elif [ $# -ge 1 ]; then
		pid=$@
	else
		pid=""
	fi
	
	echo $pid
}

function find_unused_port() {
	read l u < /proc/sys/net/ipv4/ip_local_port_range
	while :; do
    	for (( port = $l ; port <= $u ; port++ )); do
    		break 2
   		done
	done
	
	echo $port
}

function start_server() {
	[ $# -eq 0 ] && return 1
	port=$1
	nc -l "$port" &
}
	
