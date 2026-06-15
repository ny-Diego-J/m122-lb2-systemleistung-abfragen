#!/bin/bash

runtime=$(uptime | cut -d " " -f2)
time=$(date | cut -d " " -f4)
freeStorage=$(df -h / | awk 'NR==2 {print $2}' | sed 's/[A-Z]//g')
usedStorage=$(($freeStorage - $(df -h / | awk 'NR==2 {print $4}' | sed 's/[A-Z]//g')))
hostname=$(hostname)
ip=$(hostname -I | awk '{print $1}')
osName=$(grep "^NAME" /etc/os-release | cut -d "\"" -f2)
osVersion=$(grep "^VERSION_ID" /etc/os-release | cut -d "\"" -f2)
cpuModelname=$(grep "model name" -m 1 /proc/cpuinfo | cut -d ":" -f2 | cut -d " " -f2)
cpuCores=$(grep "cpu cores" -m 1 /proc/cpuinfo | cut -d ":" -f2 | cut -d " " -f2)
maxRam=$(free -h | awk 'NR==2 {print $2}')
usedRam=$(free -h | awk 'NR==2 {print $3}')

echo "runtime: $runtime"
echo "time: $time"
echo "free storage: $freeStorage GB"
echo "used storage: $usedStorage GB"
echo "hostname $hostname"
echo "ip: $ip"
echo "OS name: $osName"
echo "OS version: $osVersion"
echo "cpu modelname: $cpuModelname"
echo "cpu cores: $cpuCores"
echo "max ram: $maxRam"
echo "used ram: $usedRam"
