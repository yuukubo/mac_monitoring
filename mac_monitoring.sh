#!/bin/bash
clear
echo ""
echo "**** **** **** ****"
echo ""

echo "monitoring tool"
echo "log this mac's resource by some commands every 10 seconds"
echo ""
echo "**** **** **** ****"
echo ""

read -p "start monitoring? (y/N) : " YN
if [ "$YN" = "y" ]; then
  echo "start monitoring"
else
  echo "bye"
  echo ""
  echo "**** **** **** ****"
  echo "5 seconds wait..."
  sleep 5
  echo ""
  clear
  exit
fi
echo ""
echo "**** **** **** ****"
echo ""


DATE=`date +%Y%m%d`
DATETIME=`date +%Y%m%d_%H%M%S`
LOGD=/tmp/"$DATE"_mon_log
mkdir -p "$LOGD"

hostinfo >> "$LOGD"/`hostname`_hostinfo_"$DATETIME".txt
uptime >> "$LOGD"/`hostname`_uptime_"$DATETIME".txt

TOPLOGD="$LOGD"/"$DATE"_top
mkdir -p "$TOPLOGD"
echo "checking cpu, mem by top"
while true ; do DATETIME=`date +%Y%m%d_%H%M%S` ;  top -o mem -l 1 >> "$TOPLOGD"/`hostname`_top_"$DATETIME".txt ; sleep 10 ; done &
TOPPID=$!

PSLOGD="$LOGD"/"$DATE"_ps
mkdir -p "$PSLOGD"
echo "checking process, cpu, mem by ps"
while true ; do DATE=`date +%Y%m%d` ; DATETIME=`date +%Y%m%d_%H%M%S` ;  ps aux >> "$PSLOGD"/`hostname`_ps_"$DATETIME".txt ; sleep 10 ; done &
PSPID=$!

VMSTATLOGD="$LOGD"/"$DATE"_vm_stat
mkdir -p "$VMSTATLOGD"
echo "checking mem by vm_stat"
vm_stat -c 86400 10 >> "$VMSTATLOGD"/`hostname`_vm_stat_"$DATETIME".txt &
VMSTATPID=$!

IOSTATLOGD="$LOGD"/"$DATE"_iostat
mkdir -p "$IOSTATLOGD"
echo "checking disk io by iostat"
iostat 10 >> "$IOSTATLOGD"/`hostname`_iostat_"$DATETIME".txt &
IOSTATPID=$!

NETSTATLOGD="$LOGD"/"$DATE"_netstat
mkdir -p "$NETSTATLOGD"
echo "checking NW io by netstat"
netstat 10 >> "$NETSTATLOGD"/`hostname`_netstat_"$DATETIME".txt &
NETSTATPID=$!
echo ""
echo "**** **** **** ****"
echo ""

jobs
echo ""
echo "**** **** **** ****"
echo ""

while :
do
  read -p "stop monitoring? (y/N) : " YN
  if [ "$YN" = "y" ]; then
    echo "stop monitoring"
    break
  elif [ "$YN" = "n" ]; then
    echo "still monitoring"
  else
    echo "type y or n"
  fi
done
echo ""
echo "**** **** **** ****"
echo ""

kill -1 $TOPPID
kill -1 $PSPID
kill -1 $VMSTATPID
kill -1 $IOSTATPID
kill -1 $NETSTATPID
sleep 5
echo ""
echo "**** **** **** ****"
echo "check no jobs"

jobs
echo ""
echo "**** **** **** ****"
echo ""

echo "result : $LOGD"
echo "bye"
echo ""
echo "**** **** **** ****"
echo "10 seconds wait..."

sleep 10
echo ""
clear
open $LOGD
