#!/bin/bash
echo "========================================================================"
echo "===> Installing possible utility tools                                  "
echo "========================================================================"
echo ""

set -e

script_dir=$(dirname "$0")
while getopts ":a:" opt; do
  case ${opt} in
	a )
	  apps=$OPTARG
	  IFS=',' read -ra ADDR <<< "$apps"
	  for app in "${ADDR[@]}"; do
		case $app in
		  terminal)
			"$script_dir"/install-terminal.sh "0.41.1"
			;;
		  *)
			echo "===> Unknown application: $app"
			echo ""
			;;
		esac
	  done
	  ;;
	\? )
	  echo "Invalid option: $OPTARG" 1>&2
	  ;;
	: )
	  echo "Invalid option: $OPTARG requires an argument" 1>&2
	  ;;
  esac
done
