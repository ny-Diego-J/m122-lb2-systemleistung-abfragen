# Abfage der Systemdateien

## todo

### Formatierte Inhalte

[x] Die aktuelle Systemlaufzeit und aktuelle Systemzeit
[x] Die Grösse des belegten und freien Speichers auf dem Dateisystem
[x] Der Hostname imd IP-adresse des Systems
[x] Die Betriebssystemname und -version
[x] Der Modellname der CPU und die Anzahl der CPU-Cores
[x] Der gesamte und der genutze Arbeitsspeicher
[] Trenner und Abschluss der Tabelle für die nächste Ausgabe

### Dateiausgabe wahlweise (d.h. mit einem "switch" -f)

Gefordert ist die Ausgabe wahlweise direkt auf das
Terminal, bzw. die Console, wie auch in eine Datei.

Wenn man keine Option angibt: Nur die Terminal-Ausgabe ohne Datei.
Wenn man den "Switch" (die Option) -f angibt, soll zusätzlich die
Datei [YYYY-MM]-sys-[hostname].log erzeugt werden.
(Immer in die gleiche Datei schreiben. Das nennt man ein "Log")

Tipp: Benutzen Sie für den Timestamp date `+%Y-%m-%d` bzw. date `+%Y-%m`
und für den Hostnamen hostname oder uname -n und den Befehl df für Disk-Angaben.

### Regelmässigkeit

Binden Sie Ihr Skript in die crontab ein
und wählen Sie einen geeigneten Ausführungs-Takt.
Tipp: Prüfen Sie, ob Ihr cron eingeschaltenist mit folgendem Befehl:
service cron status

### Resultat

| Text            | Wert  |
| --------------- | ----- |
| free disk space | 80 GB |
| free memory     | 07 GB |

Tipp: Benutzen Sie den printf-Befehl
