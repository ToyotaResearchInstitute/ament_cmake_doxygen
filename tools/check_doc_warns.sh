# Copyright 2021 Toyota Research Institute
#! /bin/bash

# Inspired on https://github.com/ignitionrobotics/ign-cmake/blob/ign-cmake2/tools/doc_check.sh.

WARNINGS_LOG_FILE=$1

if [ -f $WARNINGS_LOG_FILE ]; then
  if [ -s $WARNINGS_LOG_FILE ]; then
    echo "Error. The following warnings were found in $WARNINGS_LOG_FILE."
    cat $WARNINGS_LOG_FILE
    exit 1
  else
    echo "Success. No warnings found in $WARNINGS_LOG_FILE"
    exit 0
  fi
else
  echo "The $WARNINGS_LOG_FILE file does not exist. Skipping doc check."
fi
