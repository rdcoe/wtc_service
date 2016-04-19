#! /bin/bash

test_start_httpd() {
	function get_expected() {
		echo "HTTP server starting..."
		echo "httpd returned exit code \"$i\""
	}
	
	for i in {0,1}; do
		APACHE_CTL="mock_apachectl $i"
		IS_STARTED=is_started_returns_1
		
		wc_httpd start >/dev/null
		rc=$?
		assertTrue "httpd start expected to return \"$i\" but returned \"$rc\"" "[ "${rc}" -eq "$i" ]"
		assertEquals "$(_strip_newlines $(get_expected))" "$(_strip_newlines $(cat $LOG))"
		rm -f $LOG
	done
}

test_stop_httpd() {
	function get_expected() {
		echo "HTTP server stopping..."
		echo "httpd returned exit code \"$i\""
	}
	for i in {0,1}; do
		APACHE_CTL="mock_apachectl $i"
		IS_STARTED=is_started_returns_0

		wc_httpd stop >/dev/null
		rc=$?
		assertTrue "httpd stop expected to return \"$i\" but returned \"$rc\"" "[ "${rc}" -eq "$i" ]"
		assertEquals "$(_strip_newlines $(get_expected))" "$(_strip_newlines $(cat $LOG))"
		rm -f $LOG
	done
}

. $(dirname $0)/scaffolding.bash

