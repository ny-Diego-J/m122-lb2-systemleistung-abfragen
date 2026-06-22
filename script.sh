#!/bin/bash

printInTerminal() {
    printf "%-15s : %s\n" "runtime" "$runtime"
    printf "%-15s : %s\n" "time" "$time"
    printf "%-15s : %s GB\n" "total storage" "$maxStorageGB"
    printf "%-15s : %s GB\n" "free storage" "$freeStorage"
    printf "%-15s : %s GB\n" "used storage" "$usedStorage"
    printf "%-15s : %s\n" "hostname" "$hostname"
    printf "%-15s : %s\n" "ip" "$ip"
    printf "%-15s : %s\n" "OS name" "$osName"
    printf "%-15s : %s\n" "OS version" "$osVersion"
    printf "%-15s : %s\n" "cpu modelname" "$cpuModelname"
    printf "%-15s : %s\n" "cpu cores" "$cpuCores"
    printf "%-15s : %s\n" "max ram" "$maxRam"
    printf "%-15s : %s\n" "used ram" "$usedRam"
}

printToFile() {
    jahr_monat=$(date "+%Y-%m")
    log_datei="${jahr_monat}-sys-${hostname}.log"

    {
        printf "%-15s : %s\n" "runtime" "$runtime"
        printf "%-15s : %s\n" "time" "$time"
        printf "%-15s : %s GB\n" "total storage" "$maxStorageGB"
        printf "%-15s : %s GB\n" "free storage" "$freeStorage"
        printf "%-15s : %s GB\n" "used storage" "$usedStorage"
        printf "%-15s : %s\n" "hostname" "$hostname"
        printf "%-15s : %s\n" "ip" "$ip"
        printf "%-15s : %s\n" "OS name" "$osName"
        printf "%-15s : %s\n" "OS version" "$osVersion"
        printf "%-15s : %s\n" "cpu modelname" "$cpuModelname"
        printf "%-15s : %s\n" "cpu cores" "$cpuCores"
        printf "%-15s : %s\n" "max ram" "$maxRam"
        printf "%-15s : %s\n" "used ram" "$usedRam"
        echo "----------------------------------------"
    } >>"$log_datei"
}

runtime=$(uptime -p | sed 's/up //')
time=$(date +"%H:%M:%S")

totalStorageMB=$(df -m / | awk 'NR==2 {print $2}')
availableStorageMB=$(df -m / | awk 'NR==2 {print $4}')
usedStorageMB=$(df -m / | awk 'NR==2 {print $3}')

maxStorageGB=$((totalStorageMB / 1024))
freeStorage=$((availableStorageMB / 1024))
usedStorage=$((usedStorageMB / 1024))

hostname=$(cat /etc/hostname)

ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -n1)
[ -z "$ip" ] && ip=$(ip addr | grep -w inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n1)

if [ -f /etc/os-release ]; then
    source /etc/os-release
    osName=$NAME
    osVersion=${VERSION_ID:-"Rolling Release"}
else
    osName="Linux"
    osVersion="Unknown"
fi

cpuModelname=$(grep "model name" -m 1 /proc/cpuinfo | cut -d ":" -f2 | sed 's/^[ \t]*//')
cpuCores=$(nproc)
maxRam=$(free -h | awk 'NR==2 {print $2}')
usedRam=$(free -h | awk 'NR==2 {print $3}')

case "$#" in
0)
    printInTerminal
    ;;
1)
    if [ "$1" = "-f" ]; then
        printToFile
    else
        echo "Invalid flag: $1"
        echo "Usage: $0 [-f]"
        exit 1
    fi
    ;;
*)
    # Mehr als eine Option angegeben
    echo "Too many arguments."
    echo "Usage: $0 [-f]"
    exit 1
    ;;
esac
