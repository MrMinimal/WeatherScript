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

	while getopts ":c: :h :a :t :w :p" opt; do
	 case $opt in
	 	# Stadt
	 	c)
			city=$OPTARG		# wenn kein Argument folgt, wird der case :) aufgerufen

			# TODO: check if city starts with "-" which means that there was no option provided -> exit
			# TODO: check if city is empty
			;;
	 	# Hilfe
	    h)
			printhelp=1
			exit 1				# Es macht keinen Sinn das script weiter auszuführen, wenn der user den Befehl nicht versteht
			;;

		# Alle Daten
		a)
			showTemp=1
			showPress=1
			showWindSpd=1
			showWindDir=1
			;;
			
		# Temperatur
	    t)
	    	showTemp=1
	    	;;

	    # Winddaten
	    w)
	    	showWindSpd=1
	    	showWindDir=1
	    	;;

	    # Druckdaten
	    p)
	    	showPress=1
	    	;;

	    # Alle anderen Parameter
	    \?)
		    echo "Unknown option: -$OPTARG \n"
		    printhelp=1
		    exit 1
		    ;;

		# Wenn Optionen fehlen, falls ein Argument Befehle erwartet
		:)
			echo "Option -$OPTARG requires an argument"
			exit
			;;
	  esac
	done

	# TODO: make sure that city was set, otherwise abort

	# TODO: ping server before api request



	# API Anfrage
	response=`curl -s "api.openweathermap.org/data/2.5/weather?q="$city"&units=metric&APPID="$appid""`

	echo "== Weather for $city =="

	# Temperatur
	if [[ $showTemp -eq 1 ]]
	then
		temperature=`sed -n 's/\(.*\)\("temp":\)\(.*\)\(,"pressure"\)\(.*\)/\3/p' <<< $response`

		echo -e "Temperature:\t$temperature degrees Celsius"
	fi

	# Windgeschwindigkeit
	if [[ $showWindSpd -eq 1 ]]
	then
		windspeed=`sed -n 's/\(.*\)\("speed":\)\(.*\)\(,"deg"\)\(.*\)/\3/p' <<< $response`

		echo -e "Windspeed:\t$windspeed meters per second"
	fi

	# Windrichtung
	if [[ $showWindDir -eq 1 ]]
	then
		winddir=`sed -n 's/\(.*\)\("deg":\)\(.*\)\(},"clouds"\)\(.*\)/\3/p' <<< $response`

		echo -e "Winddir:\t$winddir degrees"
	fi

	# Luftdruck
	if [[ $showPress -eq 1 ]]
	then
		pressure=`sed -n 's/\(.*\)\("pressure":\)\(.*\)\(,"humidity"\)\(.*\)/\3/p' <<< $response`

		echo -e "Pressure\t$pressure hPa"
	fi	

# =========================================== EXIT ============================================