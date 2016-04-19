#! /bin/bash

# override functions
write_pid() {
	return 0
}

find_parent_pid() {
	echo "0"
}

test_start_wc() {
	function get_expected() {
		echo "Windchill server starting..."
		echo "windchill start returned exit code \"$i\""
	}
	for i in {0,1}; do
		WINDCHILL="mock_windchill $i"
		IS_STARTED="is_started_returns_1_then_returns_0"

		windchill start >/dev/null
		rc=$?
		assertTrue "windchill start expected to return \"$i\" but returned \"$rc\"" "[ "${rc}" -eq "$i" ]"
		assertEquals "$(_strip_newlines $(get_expected))" "$(_strip_newlines $(cat $LOG))"
		rm -f $LOG
	done
}

test_stop_wc() {
	function get_expected() {
		echo "Windchill server stopping..."
		echo "windchill stop returned exit code \"$i\""
	}
	for i in {0,1}; do
		WINDCHILL="mock_windchill $i"
		IS_STARTED="is_started_returns_0_then_returns_1"
		
		windchill stop >/dev/null
		rc=$?
		assertTrue "windchill stop expected to return \"$i\" but returned \"$rc\"" "[ "${rc}" -eq "$i" ]"
		assertEquals "$(_strip_newlines $(get_expected))" "$(_strip_newlines $(cat $LOG))"
		rm -f $LOG
	done
}

. $(dirname $0)/scaffolding.bash
