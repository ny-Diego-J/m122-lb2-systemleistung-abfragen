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

# Ai für Webseite aufbau/styling
createWebsite() {
    htmlFile="./index.html"

    # Optionale Berechnung der Prozentwerte für die Ampel-Logik
    # Verhindert Division durch 0, falls Variablen leer sind
    if [ "$maxStorageGB" -gt 0 ]; then
        storagePercent=$((100 * usedStorage / maxStorageGB))
    else
        storagePercent=0
    fi

    # Extrahiere reine Zahlen aus free -h für eine ungefähre Prozentberechnung
    ramMaxNum=$(echo "$maxRam" | sed 's/[A-Za-z]//g' | tr ',' '.')
    ramUsedNum=$(echo "$usedRam" | sed 's/[A-Za-z]//g' | tr ',' '.')
    # Einfache Ganzzahlberechnung für die Bash:
    if [ -n "$ramMaxNum" ] && [ -n "$ramUsedNum" ]; then
        ramPercent=$(awk "BEGIN {print int(($ramUsedNum / $ramMaxNum) * 100)}")
    else
        ramPercent=0
    fi

    # Ampel-Farbe für Storage bestimmen
    if [ "$storagePercent" -gt 90 ]; then
        storageClass="status-red"
    elif [ "$storagePercent" -gt 70 ]; then
        storageClass="status-yellow"
    else
        storageClass="status-green"
    fi

    # Ampel-Farbe für RAM bestimmen
    if [ "$ramPercent" -gt 90 ]; then
        ramClass="status-red"
    elif [ "$ramPercent" -gt 70 ]; then
        ramClass="status-yellow"
    else
        ramClass="status-green"
    fi

    # HTML-Inhalt schreiben via Here-Document
    cat <<EOF >"$htmlFile"
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Systemleistung Dashboard - $hostname</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Inter, sans-serif; background-color: #0f172a; color: #e2e8f0; padding: 30px; line-height: 1.5; }
        .container { max-width: 1000px; margin: 0 auto; }
        header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 20px; border-bottom: 2px solid #1e293b; margin-bottom: 30px; }
        h1 { color: #38bdf8; font-size: 28px; font-weight: 600; }
        .meta-info { font-size: 14px; color: #94a3b8; text-align: right; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1-fr)); gap: 20px; margin-bottom: 30px; }
        .card { background: #1e293b; padding: 20px; border-radius: 12px; border: 1px solid #334155; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
        .card-title { font-size: 12px; uppercase; color: #64748b; font-weight: 700; margin-bottom: 5px; }
        .card-value { font-size: 20px; font-weight: 600; color: #f1f5f9; }
        table { width: 100%; border-collapse: separate; border-spacing: 0; border-radius: 12px; overflow: hidden; border: 1px solid #334155; margin-top: 20px; }
        th, td { padding: 14px 20px; text-align: left; }
        th { background-color: #0f172a; color: #38bdf8; font-size: 13px; text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 2px solid #334155; }
        td { background-color: #1e293b; border-bottom: 1px solid #334155; font-size: 15px; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background-color: #24334d; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; text-align: center; min-width: 80px; }
        .status-green { background-color: #065f46; color: #34d399; border: 1px solid #059669; }
        .status-yellow { background-color: #78350f; color: #fbbf24; border: 1px solid #d97706; }
        .status-red { background-color: #991b1b; color: #f87171; border: 1px solid #dc2626; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div>
                <h1>📊 System Dashboard</h1>
                <p style="color: #94a3b8;">Live-Statusberichte der Systemleistung</p>
            </div>
            <div class="meta-info">
                <div><strong>Hostname:</strong> $hostname</div>
                <div><strong>IP-Adresse:</strong> $ip</div>
            </div>
        </header>

        <div class="grid">
            <div class="card">
                <div class="card-title">OS & Version</div>
                <div class="card-value">$osName</div>
                <div style="font-size: 13px; color: #94a3b8;">$osVersion</div>
            </div>
            <div class="card">
                <div class="card-title">System Uptime</div>
                <div class="card-value">$runtime</div>
                <div style="font-size: 13px; color: #94a3b8;">Generiert um: $time</div>
            </div>
            <div class="card">
                <div class="card-title">CPU Kerne</div>
                <div class="card-value">$cpuCores Cores</div>
                <div style="font-size: 13px; color: #94a3b8; text-overflow: ellipsis; white-space: nowrap; overflow: hidden;" title="$cpuModelname">$cpuModelname</div>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th style="width: 30%;">Metrik</th>
                    <th style="width: 50%;">Details</th>
                    <th style="width: 20%; text-align: center;">Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Arbeitsspeicher</strong></td>
                    <td>Belegt: $usedRam / Gesamt: $maxRam ($ramPercent%)</td>
                    <td style="text-align: center;"><span class="badge $ramClass">${ramPercent}%</span></td>
                </tr>
                <tr>
                    <td><strong>Gesamtspeicher (Disk)</strong></td>
                    <td>Gesamtgröße: $maxStorageGB GB</td>
                    <td style="text-align: center;"><span class="badge status-green">OK</span></td>
                </tr>
                <tr>
                    <td><strong>Freier Speicher</strong></td>
                    <td>Verfügbar: $freeStorage GB</td>
                    <td style="text-align: center;"><span class="badge status-green">OK</span></td>
                </tr>
                <tr>
                    <td><strong>Belegter Speicher</strong></td>
                    <td>Auslastung: $usedStorage GB ($storagePercent%)</td>
                    <td style="text-align: center;"><span class="badge $storageClass">${storagePercent}%</span></td>
                </tr>
            </tbody>
        </table>
    </div>
</body>
</html>
EOF
    echo "Dashboard erfolgreich exportiert nach: $htmlFile"
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
    createWebsite
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

# in praxis auslagern in ~/.config/sysdata
if [ -f ./mail.conf ]; then
    # holt infos aus mail.conf
    source ./mail.conf
    maxValue=$maxDiskValue
    address=$mailAddress

    currentDiskUssage=$(df -h / | awk 'NR==2 {print $5}' | cut -d% -f1)

    if [ "$currentDiskUssage" -gt "$maxValue" ]; then
        betreff="WARNING: Crittical disk ussage: ($currentDiskUssage%)"
        inhalt="The disk as exceedet the threshould value of ($maxValue%) and is at ($currentDiskUssage%)"

        # Komplet ai für Mailing
        GMAIL_USER="bash57003@gmail.com"
        GMAIL_APP_PASS="tecn sayh qvtw ouzc"
        swaks --to "$address" \
            --from "$GMAIL_USER" \
            --server "smtp.gmail.com" \
            --port 587 \
            --tls \
            --auth LOGIN \
            --auth-user "$GMAIL_USER" \
            --auth-password "$GMAIL_APP_PASS" \
            --header "$betreff" \
            --body "$inhalt" >/dev/null 2>&1
    fi
fi
