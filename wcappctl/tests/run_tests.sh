#!/bin/bash

export DEBUG=false
export testdir=$(dirname $0)
declare -a tests

function usage() {
	echo
	echo "Usage: [TEST_CASES=\"[test_]func1 ... [test_]funcN\"] $(basename $0) [-d][-t \"{filenames}\"]"
	echo "       -d: turn debug mode on"
	echo "       -t: include specific test files - quoted, space-delimited file list"
	echo "	         e.g., -t \"progname1 progname2 etc.\""
	echo "           Note that the file list will attempt to resolve filenames by prepending test_ and "
	echo "           suffixing .sh as necessary" 
	echo "       TEST_CASES is an environment variable that can be used to indicate specific test functions to run"
	echo
}

function add_test() {
	local test="${testdir}/$1"
	echo "adding test program: $test"
	tests+=($test)
}

while getopts ":dt:" opt; do
    case $opt in
        d)
        	DEBUG=true
        ;;
        t)
        	read -a args <<< "$OPTARG"
        	for f in ${args[@]}; do
        		[[ ! $f =~ test_ ]] && f="test_$f"
        		[[ ! $f =~ \.sh ]] && f="$f.sh"
        		if [ -f $testdir/$f ]; then
        			add_test $f
        		else
        			echo "ignoring $f"
        		fi
        	done
        ;;
        \?)
			echo "Incorrect argument specified: -$OPTARG"
			usage
			exit 1
        ;;
    esac
done

if [ ${#tests[@]} -eq 0 ]; then 
	for f in $(ls -B ${testdir} | egrep --regexp=test_); do
		add_test $f
	done
fi

echo
echo "Running Windchill control script tests..."
echo
        
for test in ${tests[@]}; do
	$test
done