#! /bin/bash

local_setUp() {
    pidfile=/tmp/shunit2.pid
    command=$(basename $0)
    pid=$$
}	

test_write_pid() {
    write_pid $command $pidfile $pid 
    p=$(cat $pidfile)
    assertEquals "expected same pid to be returned." "$pid" "$p"
    rm $pidfile
}

test_write_pid_when_pid_exists_and_server_stopped_removes_pid_and_creates_new_pidfile() {
	# make up pid that will never match a running process
	read pid_max < /proc/sys/kernel/pid_max
	pid=$((pid_max + 1))
	echo $pid > $pidfile
    msg=$(write_pid $command $pidfile $pid)
    rc=$?
    p=$(cat $pidfile)
    assertEquals "pid file exists but process stopped.  Removing pid file." "$msg"
    assertEquals "0" "$rc"
    assertEquals "$pid" "$p"
    rm $pidfile
}

test_write_pid_when_program_running_does_nothing() {
	echo $pid > $pidfile 
    msg=$(write_pid $command $pidfile $pid)
    assertEquals "expected to be informed that $command is already running." "$command ($pid) is currently running." "$msg"
    rm $pidfile
}

test_is_listener_active_when_server_address_wrong_returns_1() {
	rm -f $LOG
	address=169.254.1.1
	port=80
	
	msg=$(is_listener_active $address $port)
	assertEquals "Could not connect to server, $address" "$(cat $LOG)" 
}


test_is_listener_active_when_server_stopped() {
	rm -f $LOG
	port=$(find_unused_port)

	netstat -l --numeric-ports | awk '{print $4}' | awk -F ':' '{print $2}' | grep -w $port >/dev/null
	assertFalse "expected server to be stopped" "$?"
	
	is_listener_active 127.0.0.1 $port >/dev/null
	assertEquals "server is accessible but should not be." "1" "$?" 
}

test_is_listener_active_when_server_running() {
	rm -f $LOG
	port=$(find_unused_port)
	start_server $port
	pid=$!
	netstat -natp 2>/dev/null | awk '{print $4}' | awk -F ':' '{print $2}' | grep -w $port >/dev/null
	port_check=$?
	netstat -natp 2>/dev/null | awk '{print $7}' | awk -F '/' '{print $1}' | grep -w $pid >/dev/null
	pid_check=$?
	assertTrue "expected port to be in use by server" "[[ $port_check -eq 0 && $pid_check -eq 0 ]]"
	
	is_listener_active 127.0.0.1 $port >/dev/null
	assertEquals "server should be accessible." "0" "$?" 
	
	kill -sigkill $pid 2>/dev/null
}

test_rotate_log() {
	rm -f ${LOG}* 1>&2 2>/dev/null
	
	echo "this is a test log" > $LOG
	rotate_log $LOG
	assertTrue 'failed log rotation test' "[ -f $newlogfile.gz ]"
	
	rm ${LOG}*
}	
	
test_rotate_log_versions_old_logs() {
	rm ${LOG}* 1>&2 2>/dev/null
	echo "this is a test log" > $LOG
	# create a backup
	rotate_log $LOG
	# create a second backup with same time stamp 
	rotate_log $LOG

	count="$(ls ${LOG}* | wc -l)"
	assertEquals "wrong number of log files present" "3" "$count"
	rm ${LOG}*
}

. $(dirname $0)/scaffolding.bash