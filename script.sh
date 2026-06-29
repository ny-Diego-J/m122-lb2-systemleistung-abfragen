#!/bin/bash

printInTerminal() {
    formatLine="----------------|--"
    formatLine+=$(printf '%0.s-' $(seq 1 "$size")) # formatline mit angepasster länge
    # "" ist zählt als letztes argument bei %-*s als nichts
    printf "|%s|\n" "$formatLine"
    printf "|%-15s | %s %-*s|\n" "Text" "Wert" "$((size - 4))" ""
    printf "|%s|\n" "$formatLine"
    printf "|%-15s | %s %-*s|\n" "runtime" "$runtime" "$((size - ${#runtime}))" ""
    printf "|%-15s | %s %-*s|\n" "time" "$time" "$((size - ${#time}))" ""
    printf "|%-15s | %s GB %-*s|\n" "total storage" "$maxStorageGB" "$((size - ${#maxStorageGB} - 3))" ""
    printf "|%-15s | %s GB %-*s|\n" "free storage" "$freeStorage" "$((size - ${#freeStorage} - 3))" ""
    printf "|%-15s | %s GB %-*s|\n" "used storage" "$usedStorage" "$((size - ${#usedStorage} - 3))" ""
    printf "|%-15s | %s GB %-*s|\n" "used storage" "$usedStorage" "$((size - ${#usedStorage} - 3))" ""
    printf "|%-15s | %s %-*s|\n" "hostname" "$hostname" "$((size - ${#hostname}))" ""
    printf "|%-15s | %s %-*s|\n" "ip" "$ip" "$((size - ${#ip}))" ""
    printf "|%-15s | %s %-*s|\n" "OS name" "$osName" "$((size - ${#osName}))" ""
    printf "|%-15s | %s %-*s|\n" "OS version" "$osVersion" "$((size - ${#osVersion}))" ""
    printf "|%-15s | %s %-*s|\n" "cpu modelname" "$cpuModelname" "$((size - ${#cpuModelname}))" ""
    printf "|%-15s | %s %-*s|\n" "cpu cores" "$cpuCores" "$((size - ${#cpuCores}))" ""
    printf "|%-15s | %s %-*s|\n" "max ram" "$maxRam" "$((size - ${#maxRam}))" ""
    printf "|%-15s | %s %-*s|\n" "used ram" "$usedRam" "$((size - ${#usedRam}))" ""
    printf "|%s|\n" "$formatLine"
}

printToFile() {
    jahr_monat=$(date "+%Y-%m")
    log_datei="${jahr_monat}-sys-${hostname}.log"
    formatLine="----------------|--"
    formatLine+=$(printf '%0.s-' $(seq 1 "$size"))
    {
        printf "|%s|\n" "$formatLine"
        printf "|%-15s | %s %-*s|\n" "Text" "Wert" "$((size - 4))" ""
        printf "|%s|\n" "$formatLine"
        printf "|%-15s | %s %-*s|\n" "runtime" "$runtime" "$((size - ${#runtime}))" ""
        printf "|%-15s | %s %-*s|\n" "time" "$time" "$((size - ${#time}))" ""
        printf "|%-15s | %s GB %-*s|\n" "total storage" "$maxStorageGB" "$((size - ${#maxStorageGB} - 3))" ""
        printf "|%-15s | %s GB %-*s|\n" "free storage" "$freeStorage" "$((size - ${#freeStorage} - 3))" ""
        printf "|%-15s | %s GB %-*s|\n" "used storage" "$usedStorage" "$((size - ${#usedStorage} - 3))" ""
        printf "|%-15s | %s GB %-*s|\n" "used storage" "$usedStorage" "$((size - ${#usedStorage} - 3))" ""
        printf "|%-15s | %s %-*s|\n" "hostname" "$hostname" "$((size - ${#hostname}))" ""
        printf "|%-15s | %s %-*s|\n" "ip" "$ip" "$((size - ${#ip}))" ""
        printf "|%-15s | %s %-*s|\n" "OS name" "$osName" "$((size - ${#osName}))" ""
        printf "|%-15s | %s %-*s|\n" "OS version" "$osVersion" "$((size - ${#osVersion}))" ""
        printf "|%-15s | %s %-*s|\n" "cpu modelname" "$cpuModelname" "$((size - ${#cpuModelname}))" ""
        printf "|%-15s | %s %-*s|\n" "cpu cores" "$cpuCores" "$((size - ${#cpuCores}))" ""
        printf "|%-15s | %s %-*s|\n" "max ram" "$maxRam" "$((size - ${#maxRam}))" ""
        printf "|%-15s | %s %-*s|\n" "used ram" "$usedRam" "$((size - ${#usedRam}))" ""
        printf "|%s|\n" "$formatLine"
    } >>"$log_datei"
}

size=0

runtime=$(uptime -p | sed 's/up //')
if [ "${#runtime}" -gt "$size" ]; then
    size="${#runtime}"
fi
time=$(date +"%H:%M:%S")
if [ "${#time}" -gt "$size" ]; then
    size="${#time}"
fi

totalStorageMB=$(df -m / | awk 'NR==2 {print $2}')
availableStorageMB=$(df -m / | awk 'NR==2 {print $4}')
usedStorageMB=$(df -m / | awk 'NR==2 {print $3}')

maxStorageGB=$((totalStorageMB / 1024))
if [ "${#maxStorageGB}" -gt "$size" ]; then
    size="${#maxStorageGB}"
fi
freeStorage=$((availableStorageMB / 1024))
if [ "${#freeStorage}" -gt "$size" ]; then
    size="${#time}"
fi
usedStorage=$((usedStorageMB / 1024))
if [ "${#usedStorage}" -gt "$size" ]; then
    size="${#usedStorage}"
fi

hostname=$(cat /etc/hostname)
if [ "${#hostname}" -gt "$size" ]; then
    size="${#hostname}"
fi

ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}' | head -n1)
# Ki für fallback fals ip nicht gefunden wurde
[ -z "$ip" ] && ip=$(ip addr | grep -w inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n1)

if [ "${#ip}" -gt "$size" ]; then
    size="${#ip}"
fi

# ki für verbesserte text extraction als mit grep
if [ -f /etc/os-release ]; then
    source /etc/os-release
    osName=$NAME
    osVersion=${VERSION_ID:-"Rolling Release"}
else
    osName="Linux"
    osVersion="Unknown"
fi

if [ "${#osName}" -gt "$size" ]; then
    size="${#osName}"
fi

if [ "${#osVersion}" -gt "$size" ]; then
    size="${#osVersion}"
fi

# Ki für genaue extraction von name ohne leerzeichen
cpuModelname=$(grep "model name" -m 1 /proc/cpuinfo | cut -d ":" -f2 | sed 's/^[ \t]*//')
if [ "${#cpuModelname}" -gt "$size" ]; then
    size="${#cpuModelname}"
fi

cpuCores=$(nproc)
if [ "${#cpuCores}" -gt "$size" ]; then
    size="${#cpuCores}"
fi

maxRam=$(free -h | awk 'NR==2 {print $2}')
if [ "${#maxRam}" -gt "$size" ]; then
    size="${#maxRam}"
fi

usedRam=$(free -h | awk 'NR==2 {print $3}')
if [ "${#usedRam}" -gt "$size" ]; then
    size="${#usedRam}"
fi

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
    echo "Too many arguments."
    echo "Usage: $0 [-f]"
    exit 1
    ;;
esac
