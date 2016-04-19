#! /bin/bash

test_start_ds() {
    function get_expected() {
        echo "WindchillDS server starting..."
        echo "start-ds returned exit code \"$i\""
    }
    
    # loop counters are being used by the mocking functions to force an 
    #+ exit status matching the counter  
    for i in {0,1}; do
        START_DS="mock_start_ds $i"
        IS_STARTED=is_started_returns_1

        ds start >/dev/null
        rc=$?
        assertTrue "start-ds expected to return \"$i\" but returned \"$rc\"" "[ "${rc}" -eq "$i" ]"
        assertEquals "$(_strip_newlines $(get_expected))" "$(_strip_newlines $(cat $LOG))"
        rm -f $LOG
    done
}

test_stop_ds() {
    function get_expected() {
        echo "WindchillDS server stopping..."
        echo "stop-ds returned exit code \"$i\""
    }

    for i in {0,1}; do
        STOP_DS="mock_stop_ds $i"
		IS_STARTED=is_started_returns_0

        ds stop >/dev/null
        rc=$?
        assertTrue "stop-ds expected to return $i but returned \"$rc\"" "[ "${rc}" -eq "$i" ]"
        assertEquals "$(_strip_newlines $(get_expected))" "$(_strip_newlines $(cat $LOG))"
        rm -f $LOG
    done
}

. $(dirname $0)/scaffolding.bash
