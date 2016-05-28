#!/bin/bash
#
# Dieses Script gibt die Wetterdaten für eine gewisse Stadt an
# Dazu wird die API von http://openweathermap.org genutzt
#
# Beispiel-Aufruf:
# ./weather.sh -c "London" -twp
#

# =========================================== TODO ============================================
# TODO: Vor Abgabe alle Tabs durch spaces ersetzten (dann fällt kopierter Code nicht auf)

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
			echo -e "\nUsage: $0 -c [City] [OPTIONS]\n"
			echo -e "Example:"
			echo -e "$0 -c London -twp"
		fi
	}

# =========================================== ENTRY ===========================================

	# Sicher gehen, dass die Hilfe am Ende des Scripts einmalig aufgerufen wird
	trap usageHint EXIT

	# Intro
	echo -e "Weather Script"
	echo -e "by Tom Langwaldt und David Becker\n"

	if [[ $# -eq 0 ]];
	then
	    printhelp=1
	    exit 1
	fi

	while getopts ":c: :h :a :t :w :p" opt; do
	 case $opt in
	 	# Stadt
	 	c)
			city=$OPTARG		# wenn kein Argument folgt, wird der case :) aufgerufen

			if [[ -z "$city" ]]; 
			then
		    	echo "Error: City name could not be read" >&2
		    	printhelp=1
		    	exit 1
			fi

			if [[ ${city:0:1} == '-' ]]
			then
			    echo "Error: -c expects an argument" >&2
		    	printhelp=1
		    	exit 1
			fi
			;;
	 	# Hilfe
	    h)
			printhelp=1
			exit 1
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
		    echo "Error: Unknown option: -$OPTARG \n" >&2
		    printhelp=1
		    exit 1
		    ;;

		# Wenn Optionen fehlen, falls ein Argument Befehle erwartet
		:)
			echo "Error: Option -$OPTARG requires an argument" >&2
			printhelp=1
			exit
			;;
	  esac
	done

	# TODO: ping server before api request



	# API Anfrage
	response=`curl -s "api.openweathermap.org/data/2.5/weather?q="$city"&units=metric&APPID="$appid""`

	echo $response

	echo "== Weather for $city =="

	# Temperatur
	if [[ $showTemp -eq 1 ]]
	then
		temperatureInt=`sed -n 's/\(.*\)\("temp":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
		temperatureFrac=`sed -n 's/\(.*\)\("temp":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

		temperature=$temperatureInt

		if [[ $temperatureFrac ]]
		then
			temperature=$temperature.$temperatureFrac
		fi		

		echo -e "Temperature:\t$temperature degrees Celsius"
	fi

	# Windgeschwindigkeit
	if [[ $showWindSpd -eq 1 ]]
	then
		windspeedInt=`sed -n 's/\(.*\)\("speed":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
		windspeedFrac=`sed -n 's/\(.*\)\("speed":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

		windspeed=$windspeedInt

		if [[ $windspeedFrac ]]
		then
			windspeed=$windspeed.$windspeedFrac
		fi

		echo -e "Windspeed:\t$windspeed meters per second"
	fi

	# Windrichtung
	if [[ $showWindDir -eq 1 ]]
	then
		winddirInt=`sed -n 's/\(.*\)\("deg":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
		winddirFrac=`sed -n 's/\(.*\)\("deg":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

		winddir=$winddirInt

		if [[ $winddirFrac ]]
		then
			winddir=$winddir.$winddirFrac
		fi

		# Sicher gehen, dass überhaupt eine Windrichtung gemessen wurde
		if [[ $winddir ]]; 
		then
	    	echo -e "Winddir:\t$winddir degrees"
		fi
	fi

	# Luftdruck
	if [[ $showPress -eq 1 ]]
	then
		pressureInt=`sed -n 's/\(.*\)\("pressure":\)\([0-9]*\)\(.*\)/\3/p' <<< $response`
		pressureFrac=`sed -n 's/\(.*\)\("pressure":\)\([0-9]*\)\(.\)\([0-9]*\)\(.*\)/\5/p' <<< $response`

		pressure=$pressureInt

		if [[ $pressureFrac ]]
		then
			pressure=$pressure.$pressureFrac
		fi

		echo -e "Pressure\t$pressure hPa"
	fi	

# =========================================== EXIT ============================================