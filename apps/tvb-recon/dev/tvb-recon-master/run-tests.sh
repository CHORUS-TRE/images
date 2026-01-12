#!/bin/bash

# ignore extern and scripts under dev
ignores=""
for ign in extern docs/bin/dev env; do ignores="--ignore=$ign $ignores"; done

# TODO adapt for different datasets, etc
export SUBJECTS_DIR=`pwd`
export SUBJECT='bnm'

# run 'em
pytest --cov-config .coveragerc --cov=tvb $ignores
