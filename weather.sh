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

	# Flags [0=N, 1=J]
	printhelp=0									# Soll Hilfe ausgegeben werden?
	showTemp=0									# Soll Luftdruck ausgegeben werden?
	showWindDir=0								# Soll Windrichtung ausgegeben werden?
	showWindSpd=0								# Soll Windgeschwindigkeit ausgegeben werden?
	showPress=0									# Soll Luftdruck ausgegeben werden?

	# Values
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
			echo "Usage: $0 [cityName, postCode] TODO: ADD FURTHER ARGUMENTS"
		fi
	}

# =========================================== ENTRY ===========================================

	# Sicher gehen, dass die Hilfe am Ende des Scripts einmalig aufgerufen wird
	trap usageHint EXIT

	# Intro
	echo -e "Weather Script"
	echo -e "by Tom Langwaldt und David Becker\n"

	while getopts ":h :t :w :p" opt; do
	 case $opt in
	 	# Hilfe
	    h)
			printhelp=1
			;;

		# Temperatur
	    t)
	    	showTemp=1
	    	;;

	    # Winddaten
	    w)
	    	
	    	;;

	    # Druckdaten
	    p)
	    	
	    	;;

	    # Alle anderen Parameter
	    \?)
		    echo "Invalid option: -$OPTARG \n"
		    printhelp=1
		    exit 1
		    ;;
	  esac
	done


	# TODO: ping server before api request

	# API Anfrage
	response=`curl -s "api.openweathermap.org/data/2.5/weather?q="$city"&units=metric&APPID="$appid""`

	# Einlesen der interessanten Daten in Variablen
	temperature=`sed -n 's/\(.*\)\("temp":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`
	winddir=`sed -n 's/\(.*\)\("deg":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`
	windspeed=`sed -n 's/\(.*\)\("speed":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`
	pressure=`sed -n 's/\(.*\)\("pressure":\)\(-*[0-9]\+\.[0-9]\+\)\(.*\)/\3/p' <<< $response`

	if [[ $showTemp -eq 1 ]]
	then
		echo "TODO: temp ausgeben"
	fi