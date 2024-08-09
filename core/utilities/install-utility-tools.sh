#!/bin/bash
echo "========================================================================"
echo "===> Installing possible utility tools                                  "
echo "========================================================================"
echo ""

set -e

while getopts ":a:" opt; do
  case ${opt} in
	a )
	  apps=$OPTARG
	  IFS=',' read -ra ADDR <<< "$apps"
	  for app in "${ADDR[@]}"; do
		case $app in
		  terminal)
			./install-terminal.sh
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
