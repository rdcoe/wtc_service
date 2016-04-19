#! /bin/bash
local_setUp() {
	rm -f pidfile
	cmd=
	optArg=
}

test_expect_root() {
	id="$(get_uid)"
	assertEquals "ensure script is run by root" "0" "$id"
}

test_load_config() {
	assertNotNull 'failed test' "$FUNCTIONS"
}

test_find_parent_pid() {
	pidofproc() {
		pid=$(mock_pidofproc $@)
		echo "$pid"
	}
	
	pid=$(find_parent_pid)
	assertEquals "incorrect pid returned" "0" "$pid"
	
	pid=$(find_parent_pid 20)
	assertEquals "incorrect pid returned" "20" "$pid"
	
	pid=$(find_parent_pid "20 18 23 21")
	assertEquals "incorrect pid returned" "18" "$pid"
}

test_status() {
	function pidof() {
		return 0
	}
	
	local arr=( "httpd:$HTTPD_PID" "Windchill:$WINDCHILL_PID" "WindchillDS:$DS_PID" )
	for entry in ${arr[@]}; do
		declare -a temp=(${entry})
		stat=$(my_status temp[@])
		assertEquals "${temp%%:*} is stopped" "$stat"
	done
}

test_is_started_returns_0_when_process_running_and_no_pidfile() {
	pidfile=/tmp/pidfile
	cmd=$0

	function find_parent_pid() {
		echo $$
	}
	
	is_started $pidfile $cmd $optArg
	assertTrue "expected to find pid for the running test" "[ $? -eq 0 ]"
	
	rm -f $LOG
}

test_is_started_returns_0_when_pidfile_exists_and_process_running() {
	pidfile=/tmp/pidfile
	cmd=$0

	echo $$ > $pidfile

	is_started $pidfile $cmd $optArg
	assertTrue "expected to find pid for the running test" "[ $? -eq 0 ]"
	
	rm -f $LOG
}

test_is_started_returns_1_when_process_not_running() {
	pidfile=/tmp/pidfile
	cmd="dummyprog"

	echo 0 > $pidfile

	is_started $pidfile $cmd $optArg
	assertTrue "process should appear stopped" "[ $? -eq 1 ]"
	
	rm -f $LOG
}

test_is_started_returns_1_when_process_not_running_no_pidfile() {
	pidfile=/tmp/pidfile
	cmd="dummyprog"

	is_started $pidfile $cmd $optArg
	assertTrue "process should appear stopped" "[ $? -eq 1 ]"
	
	rm -f $LOG
}

test_is_stopped_returns_0_when_process_not_running() {
	pidfile=/tmp/unittest.pid
	cmd="dummyprog"

	IS_STARTED=is_started_returns_1
	
	is_stopped $pidfile $cmd $optArg
	assertTrue "process should be stopped" "[ $? -eq 0 ]"
	
	rm -f $LOG
}

test_is_stopped_returns_1_when_process_is_running() {
	pidfile=/tmp/unittest.pid
	cmd=$0

	IS_STARTED=is_started_returns_0
	
	is_stopped $pidfile $cmd $optArg
	assertTrue "process should be running" "[ $? -eq 1 ]"
	
	rm -f $LOG
}

. $(dirname $0)/scaffolding.bash
