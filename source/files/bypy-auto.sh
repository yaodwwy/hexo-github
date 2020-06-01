#!/bin/bash
ProcNumber=`ps -ef | grep -w bypy | grep -v grep | grep -v bypy-auto | wc -l`
time=$(date "+%Y%m%d-%H%M%S")
if [[ ${ProcNumber} -le 0  ]];then
   bypy syncup /mnt/baiduyun/ / --processes 2 -v > bypy${time}.log 2>&1 &
else
   ps -ef | grep -w bypy | grep -v grep | grep -v bypy-auto >> bypy.log
   echo "${time} bypy is  runnig ..." >> bypy.log
fi
