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

# TODO: -h 		# help
# TODO: -a 		# all current weather
# TODO: -w 		# alle windaten ausgeben
# TODO: -w dir 	# windrichtung
# TODO: -w spd 	# windgeschwindigkeit
# TODO: -t 		# temperatur daten ausgeben
# TODO: -p 		# luftdruck daten ausgeben

# ========================================= VARIABLES =========================================

	appid=31c8db3e5477aeac1def817cc0bc66b3		# Die app id für die API

	printhelp=0									# Soll Hilfe ausgegeben werden? [0=N, 1=J]


	city=										# Wetter für welche Stadt
	response=									# Antwort der API
	temperature=								# 
	winddir=									#
	windspeed=									#

	jsonVal=									# the return value of getJSONVal()

# ========================================= FUNCTIONS =========================================

	# Wird einmalig am Ende des Scripts aufgerufen um ggf. über die Verwendung zu informieren
	usageHint()
	{
		if [ $printhelp -eq 1 ]
		then
			echo "Usage: $0 [cityName, postCode] TODO: ADD FURTHER ARGUMENTS"
		fi
	}

# =========================================== ENTRY ===========================================

	# Sicher gehen, dass die Hilfe am Ende des Scripts einmalig aufgerufen wird
	trap usageHint EXIT

	# Intro
	echo -e "Weather Script"
	echo -e "by Tom Langwaldt und David Becker\n"

	# Sanity check ob überhaupt Argumente übergeben wurden
	if [ $# -eq 0 ]
	then
		echo -e "No arguments passsed"
		printhelp=1
		exit 1
	fi

	# Stadtnamen (auch durch Komma getrennte) einlesen
	for var in "$@"
	do
		# Sichger gehen, dass die Flags nicht dem Stadtnamen zugeordnet werden
		if [[ "$var" =~ "-" ]]
		then
			break
		fi

	    city=$city" "$var
		echo "City is $city"
	done

	# Sanity check ob der Stadtname eingegeben wurde
	if [ -z "$city" ]
	then
	    echo "Could not read city name!"
	    printhelp=1
	    exit 1
	fi

	# Iterieren über die Eingabeargumente
	while getopts "hawtp" arg; do
		case $arg in
			h)
				# TODO: display help
				printhelp=1
				;;
	        a)
	            # TODO: display "all weather"
	            ;;
			w)
				# TODO: set flag to display wind speed later
				
				;;
			t)
				# TODO: set flag to display temperature later
				
				;;
			p)
				# TODO: set flag to display pressure later
				
				;;
	        ?)
				# Bei nicht implementierten Argumenten die Hilfe ausgeben
				echo "Invalid arguments"
	            printhelp=1
	            exit
	            ;;
	    esac
	done

	# API Anfrage
	response=`curl -s "api.openweathermap.org/data/2.5/weather?q="$city"&units=metric&APPID="$appid""`

	# Einlesen der interessanten Daten in Variablen
	temperature=`sed -n 's/\(.*\)\("temp":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`
	winddir=`sed -n 's/\(.*\)\("deg":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`
	windspeed=`sed -n 's/\(.*\)\("speed":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`
	pressure=`sed -n 's/\(.*\)\("pressure":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`