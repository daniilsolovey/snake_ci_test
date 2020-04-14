#!/usr/bin/env bash

PYTHON_CALLABLE="python"

ROBOT_ARGS=

function usage()
{
    echo "Usage ./run-all-tests.sh options"
    echo ""
    echo "OPTIONS:"
    echo "  -d <driver>     Select driver: <chrome/firefox/headlesschrome/headlessfirefox>"
    echo "  -h              Show this message"
    echo "  -r              randomise the tests <tests/suites/all/none>"
    echo "  -t <subdir>     Specify /tests/<subdir> to run tests contained within"
    echo "  -x \"<args>\"   Extra arguments to pass to robot"
    echo
    exit
}

while getopts ":bc:d:hk:lm:n:r:t:u:v:wx:" opt; do
    case ${opt} in
        d)  ROBOT_ARGS+=" --variable BROWSER:${OPTARG}"
            ROBOT_ARGS+=" --metadata BROWSER:${OPTARG}"
            ;;
        h)  usage
            ;;
        r)  ROBOT_ARGS+=" --randomize ${OPTARG}"
            ;;
        t)  TESTS_SUB_DIR="${OPTARG}"
            ;;
        x)  ROBOT_ARGS+=" ${OPTARG}"
            ;;
    esac
done

# run all tests
${PYTHON_CALLABLE} -m robot --outputdir reports ${ROBOT_ARGS} ./tests/${TESTS_SUB_DIR}