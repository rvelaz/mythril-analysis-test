#!/bin/bash

SRC='./'
MYTHRIL_OPTIONS='-x'

function usage {
  echo "$0 -o 'MYTHRILL OPTIONS' -s 'SOLIDITY FILE OR PATH WITH SOLIDITY SOURCES' -r 'FILE THAT WILL STORE THE TEST RESULTS'"
  echo
  echo "Runs mythril analysis on one or more solidity files"
  echo ". It exists with code 1 if there are any errors"
  echo
  echo "Default values:"
  echo "  o: -x"
  echo "  s: ./"
  echo "    This will run tests for all the .sol files found in the current directory and its subdirectories"
  echo "r: solidity_test_results.out"
  echo
  echo "  e.g. $0 -o 'res.out'"
  echo "    Will run Mythril analysis for all the solidity files found recursively in the current directory."
  echo "    The output will be saved in the file res.out"
  echo
}

while getopts ":o:s:f:r:h" opt; do
  case $opt in
    o)
      MYTHRIL_OPTIONS=$OPTARG
      ;;
    s)
      SRC=$OPTARG
      ;;
    r)
      RESULT_FILE=$OPTARG
      ;;
    h)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

SOLIDITY_FILES=$(find $SRC -name '*.sol')

if [[ -n $RESULT_FILE && -f $RESULT_FILE ]]; then
  echo "Cleaning up: $RESULT_FILE"
  rm $RESULT_FILE
fi

ok=0
ko=0

for f in $SOLIDITY_FILES
do
  test_result=$(myth $MYTHRIL_OPTIONS $f)
  if [[ "$test_result" == "[]" || "$test_result" == "The analysis was completed successfully. No issues were detected." ]]; then
    ok=$((ok+1))
  else
    ko=$((ko+1))
  fi

  if [[ -n $RESULT_FILE ]]; then
    echo $test_result >> $RESULT_FILE
  fi
done

if [ $ko -ne 0 ];then
  exit 1
fi
