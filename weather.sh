#!/bin/bash
# Dieses Script gibt die Wetterdaten für eine gewisse Stadt an
# Dazu wird die API von http://openweathermap.org genutzt
#
# Beispiel-Aufruf:
# ./weather.sh "Berlin"
#

# =========================================== TODO ============================================

# TODO: Ggf. JSON Auslesen in eigene Funktion auslagern?
# TODO: Vor Abgabe alle Tabs durch spaces ersetzten (dann fällt kopierter Code nicht auf)

# TODO: -h --help
# TODO: -c --current
# TODO: -p --predicted
# TODO: --no-intro option
# TODO: --dialog

# ========================================= VARIABLES =========================================

	appid=31c8db3e5477aeac1def817cc0bc66b3		# Die app id für die API
	
	printhelp=0									# Soll Hilfe ausgegeben werden?
	city=										# Wetter für welche Stadt
	response=									# Antwort der API
	temperature=								# 
	winddir=									#
	windspeed=									#

# ========================================= FUNCTIONS =========================================

	# Wird einmalig am Ende des Scripts aufgerufen um ggf. über die Verwendung zu informieren
	usageHint()
	{
		if [ $printhelp -eq 1 ]
		then
			echo "Verwendung: $0 [Stadtname, PLZ] TODO: ADD FURTHER ARGUMENTS"
		fi
	}

# =========================================== ENTRY ===========================================

	# Sicher gehen, dass die Hilfe am Ende des Scripts einmalig aufgerufen wird
	trap usageHint EXIT

	# Intro
	echo -e "Wetter Script"
	echo -e "von Tom Langwaldt und David Becker\n"

	# Sanity check ob überhaupt Argumente übergeben wurden
	if [ $# -eq 0 ]
	then
		printhelp=1
		exit 1
	fi

	# Versuch den Stadtname einer Variablen zuzuweisen
	city=$1

	# Sanity check ob der Stadtname eingegeben wurde
	if [ -z $city]
	then
	    echo "Kein Stadtname eingelesen!"
	    printhelp=1
	    exit 1
	fi

	# Iterieren über die Eingabeargumente
	while getopts ":h:c:p:" opt; do
		case "${opt}" in
			s)

				;;
	        p)
	            p=${OPTARG}
	            ;;
	        *)
	            usage
	            ;;
	    esac
	done

	# API Anfrage
	response=$(curl -s "api.openweathermap.org/data/2.5/weather?q="$city"&units=metric&APPID="$appid"")

	# Einlesen der interessanten Daten in Variablen
	temperature=$(sed -n 's/\(.*\)\("temp":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response)
	winddir=$(sed -n 's/\(.*\)\("deg":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response)
	windspeed=$(sed -n 's/\(.*\)\("speed":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response)

	echo "full:"$response
	echo "temp:"$temperature
	echo "wind speed:"$windspeed
	echo $winddir " degrees"