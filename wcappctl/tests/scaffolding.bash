. /etc/rc.d/init.d/functions

function setUp() {
	SRC_DIR=${testdir}/../src
	BIN_DIR=$SRC_DIR/etc/init.d
	WC_ROOT=$SRC_DIR/ptc/Windchill_10.1
	
	CONFIG=${WC_ROOT}/config.bash
	# import config properties
	. ${CONFIG}
	
    # import functions 
	. ${FUNCTIONS}
        
    # override with mocked functions
    . ${testdir}/functions.bash
    
	#override env for test output
	LOG=/tmp/testrunner.log
	WC_ROOT=${testdir}/ptc/Windchill_10.1
		
	WINDCHILL_PID=/tmp/wcdummy.pid
	DS_PID=/tmp/dsdummy.pid
	HTTPD_PID=/tmp/httpddummy.pid
		
	is_true "$DEBUG"
    [ $? -eq 0 ] && set -x
    [ "x$(type -t local_setUp)" != "x" ] && local_setUp 
}

function tearDown() {
    set +x
}

function suite() {
	for testcase in ${TEST_CASES} ; do
	   	[[ ! $testcase =~ test_ ]] && testcase="test_$testcase"
	   	echo "adding test to suite: $testcase"
	    suite_addTest $testcase
	done
}

. /usr/share/shunit2/shunit2